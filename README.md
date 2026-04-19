# swal_rails

[![CI](https://github.com/Metalzoid/swal_rails/actions/workflows/main.yml/badge.svg)](https://github.com/Metalzoid/swal_rails/actions)
[![Gem Version](https://badge.fury.io/rb/swal_rails.svg)](https://rubygems.org/gems/swal_rails)

**SweetAlert2 v11 for Rails 7+, batteries included.**
First-class support for **importmap**, **jsbundling**, and **sprockets** — plus a Stimulus controller, auto-wired flash messages, Turbo confirm replacement, Ruby view helpers, and full I18n. Everything is configurable.

---

## Why another gem?

The existing `sweetalert2-rails` / `sweetify` gems haven't shipped a release since 2019 (SA2 was on v7 back then — it's on v11 now) and were built for the Rails 5 / UJS era. `swal_rails` is the modern replacement:

|                                  | `sweetalert2-rails` | `sweetify` | **`swal_rails`** |
| -------------------------------- | :-----------------: | :--------: | :--------------: |
| SweetAlert2 v11.x                |         no          |     no     |        yes       |
| Rails 7+ / Turbo                 |         no          |     no     |        yes       |
| Importmap                        |         no          |     no     |        yes       |
| jsbundling (esbuild/vite)        |         no          |     no     |        yes       |
| Sprockets                        |         yes         |     no     |        yes       |
| Stimulus controller              |         no          |     no     |        yes       |
| Flash auto, map per key          |         no          |   partial  |        yes       |
| Turbo `setConfirmMethod` override|         no          |     no     |        yes       |
| `data-swal-confirm` attribute    |         no          |     no     |        yes       |
| View helpers (`swal_tag`)        |         no          |     no     |        yes       |
| I18n Rails (fr/en shipped)       |         no          |     no     |        yes       |
| a11y (reduced-motion, ARIA)      |         no          |     no     |        yes       |
| Last release                     |        2019         |    2019    |    **current**   |

## Installation

Add to your `Gemfile`:

```ruby
gem "swal_rails"
```

Then:

```bash
bundle install
bin/rails g swal_rails:install           # autodetects your asset pipeline
# or force a mode:
bin/rails g swal_rails:install --assets=importmap
bin/rails g swal_rails:install --assets=jsbundling
bin/rails g swal_rails:install --assets=sprockets
```

The generator:
- copies `config/initializers/swal_rails.rb`
- pins/imports `sweetalert2` and `swal_rails` for your asset pipeline
- injects `<%= swal_rails_meta_tags %>` into your application layout

Then in your JS entrypoint (`app/javascript/application.js`):

```js
import "swal_rails"
```

That's it — flash messages now appear as toasts, and any link with `data-swal-confirm="Sure?"` shows a SweetAlert2 confirm modal.

## Configuration

`config/initializers/swal_rails.rb`:

```ruby
SwalRails.configure do |config|
  # :off | :data_attribute (default) | :turbo_override | :both
  config.confirm_mode = :turbo_override

  config.respect_reduced_motion = true
  config.expose_window_swal     = true

  config.default_options = {
    buttonsStyling: true,
    reverseButtons: false
  }

  # Map any flash key to SweetAlert2 options
  config.flash_map[:notice] = { icon: "success", toast: true, position: "top-end", timer: 3000 }
  config.flash_map[:alert]  = { icon: "error",   toast: false }
end
```

## Usage

### Flash messages

Any flash you set in a controller is shown automatically:

```ruby
flash[:notice] = "Profile updated"     # => toast top-right
flash[:alert]  = "Could not save"      # => modal
```

### Turbo confirmations

```erb
<%= button_to "Delete", post_path(@post), method: :delete,
      data: { turbo_confirm: "Really delete?" } %>
```

With `confirm_mode: :turbo_override`, this shows a SweetAlert2 dialog instead of the browser `confirm()`.

### Opt-in confirmations via data attribute

```erb
<%= link_to "Archive", archive_path, data: { swal_confirm: "Archive this item?",
                                             swal_icon: "warning" } %>
```

### Stimulus controller

```erb
<button data-controller="swal"
        data-action="click->swal#fire"
        data-swal-options-value='{"title":"Hello","icon":"success"}'>
  Ping
</button>
```

### Inline Ruby helper

```erb
<%= swal_tag(title: "Welcome", icon: "info") %>
```

### Programmatic from JS

```js
import Swal from "sweetalert2"
Swal.fire({ title: "Saved!", icon: "success" })
```

## I18n

Locales `en` and `fr` ship with the gem. To copy them into your app for customization:

```bash
bin/rails g swal_rails:locales
```

## Accessibility

- Honors `prefers-reduced-motion` (animations disabled when the OS requests it).
- SweetAlert2's built-in focus trap and ARIA roles are preserved.
- Translatable button labels via I18n.

## Requirements

- Ruby **3.2+**
- Rails **7.0+**
- Turbo (recommended)

## Credits

This gem bundles [SweetAlert2](https://sweetalert2.github.io/) by Tristan Edwards, Limon Monte and contributors, distributed under the MIT License. The full license is included at `vendor/javascript/sweetalert2/LICENSE`.

## License

`swal_rails` is released under the [MIT License](LICENSE.txt).
