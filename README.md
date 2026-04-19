<div align="center">

# 🍬 swal_rails

**SweetAlert2 v11 for Rails 7+ — batteries included.**

First-class support for **Importmap**, **jsbundling**, and **Sprockets**, with a
Stimulus controller, auto-wired flash messages, Turbo confirm replacement,
Ruby view helpers, and full I18n. Everything is configurable.

[![CI](https://github.com/Metalzoid/swal_rails/actions/workflows/main.yml/badge.svg)](https://github.com/Metalzoid/swal_rails/actions)
[![Gem Version](https://badge.fury.io/rb/swal_rails.svg)](https://rubygems.org/gems/swal_rails)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.2-CC342D.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/rails-7.0%20%E2%86%92%208.1-CC0000.svg)](https://rubyonrails.org/)
[![SweetAlert2](https://img.shields.io/badge/SweetAlert2-v11.26-3085d6.svg)](https://sweetalert2.github.io/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.txt)

</div>

---

## 📖 Table of contents

- [Why swal_rails?](#-why-swal_rails)
- [Features](#-features)
- [Compatibility](#-compatibility)
- [Installation](#-installation)
- [Quick start](#-quick-start)
- [Configuration](#%EF%B8%8F-configuration)
- [Usage](#-usage)
  - [Flash messages](#flash-messages)
  - [Turbo confirmations](#turbo-confirmations)
  - [`data-swal-confirm` attribute](#data-swal-confirm-attribute)
  - [Stimulus controller](#stimulus-controller)
  - [Ruby view helpers](#ruby-view-helpers)
  - [Programmatic JS](#programmatic-js)
- [I18n](#-i18n)
- [Accessibility](#-accessibility)
- [Asset pipelines](#-asset-pipelines)
- [Development](#-development)
- [Contributing](#-contributing)
- [Credits & license](#-credits--license)

---

## 🤔 Why swal_rails?

The existing gems haven't shipped a release since 2019 (SA2 was on **v7** back
then — it's on **v11** now) and were built for the Rails 5 / UJS era.
`swal_rails` is the modern replacement:

|                                         | `sweetalert2-rails` |   `sweetify`   |   **`swal_rails`**   |
| --------------------------------------- | :-----------------: | :------------: | :------------------: |
| SweetAlert2 v11.x                       |         ❌          |       ❌       |          ✅          |
| Rails 7+ / Turbo-native                 |         ❌          |       ❌       |          ✅          |
| Importmap                               |         ❌          |       ❌       |          ✅          |
| jsbundling (esbuild / vite / rollup)    |         ❌          |       ❌       |          ✅          |
| Sprockets                               |         ✅          |       ❌       |          ✅          |
| Stimulus controller                     |         ❌          |       ❌       |          ✅          |
| Flash auto-wire, map per key            |         ❌          |    partial     |          ✅          |
| Turbo `setConfirmMethod` override       |         ❌          |       ❌       |          ✅          |
| `data-swal-confirm` attribute           |         ❌          |       ❌       |          ✅          |
| Ruby view helpers (`swal_tag`)          |         ❌          |       ❌       |          ✅          |
| I18n Rails (fr/en shipped)              |         ❌          |       ❌       |          ✅          |
| a11y (reduced-motion, ARIA)             |         ❌          |       ❌       |          ✅          |
| Last release                            |        2019         |      2019      |    **maintained**    |

---

## ✨ Features

- 🎨 **SweetAlert2 v11** vendored and pinned — no CDN, no surprise upgrades.
- ⚡ **Three asset pipelines**: Importmap (default), jsbundling, Sprockets.
- 🔔 **Auto-wired flash** — `flash[:notice]` → toast, `flash[:alert]` → modal, fully mappable per key.
- 🛡️ **Turbo confirmations** — replace the native `confirm()` globally **or** opt-in per element.
- 🎮 **Stimulus controller** (`data-controller="swal"`) for declarative popups.
- 🧱 **Ruby view helpers** — `swal_tag`, `swal_config_meta_tag`, `swal_flash_meta_tag`.
- 🌍 **I18n ready** — `en` / `fr` locales shipped, override freely.
- ♿ **Accessibility** — honors `prefers-reduced-motion`, preserves ARIA & focus trap.
- 🧩 **Engine-based** — zero monkey-patching, follows Rails Engine conventions.

---

## 🔧 Compatibility

Tested on every combination of Ruby and Rails listed below via the
[Appraisal](https://github.com/thoughtbot/appraisal) gem:

|         | Rails 7.0 | Rails 7.1 | Rails 7.2 | Rails 8.0 | Rails 8.1 | Rails 8.1 + Sprockets |
| ------- | :-------: | :-------: | :-------: | :-------: | :-------: | :-------------------: |
| Ruby 3.2|     ✅    |     ✅    |     ✅    |     ✅    |     ✅    |           ✅          |
| Ruby 3.3|     ✅    |     ✅    |     ✅    |     ✅    |     ✅    |           ✅          |
| Ruby 3.4|     —     |     ✅    |     ✅    |     ✅    |     ✅    |           ✅          |

> **Requirements:** Ruby **≥ 3.2**, Rails **≥ 7.0**, Turbo recommended.

---

## 📦 Installation

Add this line to your application's `Gemfile`:

```ruby
gem "swal_rails"
```

Then install and run the generator:

```bash
$ bundle install
$ bin/rails g swal_rails:install
```

The generator **autodetects** your asset pipeline. You can force it:

```bash
$ bin/rails g swal_rails:install --mode=importmap   # default for new Rails apps
$ bin/rails g swal_rails:install --mode=jsbundling  # esbuild, vite, rollup
$ bin/rails g swal_rails:install --mode=sprockets   # legacy apps
```

### What the generator does

- 📄 creates `config/initializers/swal_rails.rb`
- 📌 pins (Importmap) or adds (jsbundling/sprockets) `sweetalert2` and `swal_rails`
- 💉 injects `<%= swal_rails_meta_tags %>` into `app/views/layouts/application.html.erb`
- 🌐 loads the `en` / `fr` locales

Finally, in your JS entrypoint (e.g. `app/javascript/application.js`):

```js
import "swal_rails"
```

---

## 🚀 Quick start

Thirty seconds, tops. After running the installer:

```ruby
# app/controllers/posts_controller.rb
def create
  @post = Post.create!(post_params)
  redirect_to @post, notice: "Post created!"
end
```

```erb
<%# app/views/posts/show.html.erb %>
<%= button_to "Delete", @post, method: :delete,
      data: { turbo_confirm: "Really delete this post?" } %>
```

That's it. `notice` renders as a **toast**, the delete button opens a
**SweetAlert2 modal** instead of the browser's ugly native `confirm()`.

---

## ⚙️ Configuration

Everything lives in `config/initializers/swal_rails.rb`:

```ruby
SwalRails.configure do |config|
  # ─── Confirm behavior ────────────────────────────────────────────────
  # :off            → don't touch Turbo, no data-attribute listener
  # :data_attribute → only intercept [data-swal-confirm] clicks (default)
  # :turbo_override → replace Turbo.setConfirmMethod globally
  # :both           → data-attribute + Turbo override
  config.confirm_mode = :data_attribute

  # ─── UX ──────────────────────────────────────────────────────────────
  config.respect_reduced_motion = true   # disable animations when OS asks
  config.expose_window_swal     = true   # window.Swal for console hacking

  # ─── Defaults passed to every Swal.fire call ─────────────────────────
  config.default_options = {
    buttonsStyling: true,
    reverseButtons: false,
    focusConfirm:   true,
    returnFocus:    true
  }

  # ─── Flash → Swal mapping (per key) ──────────────────────────────────
  config.flash_map[:notice]  = { icon: "success", toast: true,  position: "top-end", timer: 3000 }
  config.flash_map[:success] = { icon: "success", toast: true,  position: "top-end", timer: 3000 }
  config.flash_map[:alert]   = { icon: "error",   toast: false }
  config.flash_map[:error]   = { icon: "error",   toast: false }
  config.flash_map[:warning] = { icon: "warning", toast: true,  position: "top-end", timer: 4000 }
  config.flash_map[:info]    = { icon: "info",    toast: true,  position: "top-end", timer: 3000 }

  # ─── I18n scope (for button labels) ──────────────────────────────────
  config.i18n_scope = "swal_rails"
end
```

> 💡 **Per-key override tip:** to disable the toast for a single key without
> rewriting the whole map: `config.flash_map[:alert] = { icon: "error", toast: false }`.

---

## 🎯 Usage

### Flash messages

Any flash set from a controller is rendered automatically on page load:

```ruby
flash[:notice] = "Profile updated"   # → toast top-right
flash[:alert]  = "Could not save"    # → modal
```

Behind the scenes, the engine serializes the flash into a meta tag
(`<meta name="swal-flash" content="...">`) and the JS runtime reads it and
calls `Swal.fire(...)` with your per-key options.

---

### Turbo confirmations

Works with standard Rails / Turbo syntax:

```erb
<%= button_to "Delete", post_path(@post), method: :delete,
      data: { turbo_confirm: "Really delete?" } %>
```

When `confirm_mode` is `:turbo_override` or `:both`, `swal_rails` replaces
`Turbo.setConfirmMethod` with a SweetAlert2-backed implementation — the same
`data-turbo-confirm` attribute now shows a proper modal.

---

### `data-swal-confirm` attribute

If you don't want to override Turbo globally, opt-in per element:

```erb
<%= link_to "Archive", archive_path,
      data: { swal_confirm: "Archive this item?", swal_icon: "warning" } %>
```

Supported data attributes (any SA2 option works):

| Attribute                          | Maps to                |
| ---------------------------------- | ---------------------- |
| `data-swal-confirm`                | `text` / title prompt  |
| `data-swal-icon`                   | `icon`                 |
| `data-swal-confirm-button-text`    | `confirmButtonText`    |
| `data-swal-cancel-button-text`     | `cancelButtonText`     |
| `data-swal-options` *(JSON string)*| full options hash      |

---

### Stimulus controller

For fully declarative popups without touching JS:

```erb
<button data-controller="swal"
        data-action="click->swal#fire"
        data-swal-options-value='{"title":"Hello","icon":"success"}'>
  Ping
</button>
```

Available actions: `fire`, `confirm`.

---

### Ruby view helpers

Fire a one-shot popup directly from a view:

```erb
<%= swal_tag(title: "Welcome back!", icon: "info", timer: 2000) %>
```

Lower-level helpers (injected by the generator into your layout):

```erb
<%= swal_rails_meta_tags %>
<%# expands to: %>
<%= swal_config_meta_tag %>  <%# serializes SwalRails.configuration %>
<%= swal_flash_meta_tag %>   <%# serializes current flash, if any %>
```

---

### Programmatic JS

`Swal` is re-exported from the gem's JS runtime:

```js
import Swal from "sweetalert2"

Swal.fire({
  title: "Saved!",
  icon: "success",
  toast: true,
  position: "top-end",
  timer: 3000
})
```

If `config.expose_window_swal = true`, `window.Swal` is also available for
quick console debugging.

---

## 🌍 I18n

Locales `en` and `fr` ship with the gem. To copy them into your app for customization:

```bash
$ bin/rails g swal_rails:locales
```

Generated keys:

```yaml
en:
  swal_rails:
    confirm_button_text: "OK"
    cancel_button_text:  "Cancel"
    deny_button_text:    "No"
    close_button_aria_label: "Close this dialog"
```

The current `I18n.locale` is read on every request and injected into the
client payload — change languages, button labels follow.

---

## ♿ Accessibility

- **Reduced motion** — when `prefers-reduced-motion: reduce` is set, animations
  are disabled (`showClass`/`hideClass` emptied).
- **Focus trap & ARIA** — SweetAlert2's built-in focus management and ARIA
  roles are preserved; `returnFocus: true` brings focus back to the trigger.
- **Translatable labels** — all button / aria labels go through I18n.

---

## 🎨 Asset pipelines

`swal_rails` adapts to whichever pipeline you use — the generator picks the
right template automatically.

```
┌─ Importmap (Rails 7+ default) ───────────────────────────────────────┐
│   config/importmap.rb                                                │
│     pin "sweetalert2", to: "sweetalert2.js"                          │
│     pin "swal_rails",  to: "swal_rails.js"                           │
│   app/javascript/application.js                                      │
│     import "swal_rails"                                              │
└──────────────────────────────────────────────────────────────────────┘

┌─ jsbundling (esbuild / vite / rollup) ───────────────────────────────┐
│   package.json  →  "sweetalert2": "^11"  (your bundler resolves it)  │
│   app/javascript/application.js                                      │
│     import "swal_rails"                                              │
└──────────────────────────────────────────────────────────────────────┘

┌─ Sprockets (legacy) ─────────────────────────────────────────────────┐
│   app/assets/javascripts/application.js                              │
│     //= require sweetalert2                                          │
│     //= require swal_rails                                           │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 🧪 Development

```bash
$ git clone https://github.com/Metalzoid/swal_rails.git
$ cd swal_rails
$ bundle install
$ bundle exec rspec         # 31 examples, real headless Chromium (Cuprite)
$ bundle exec rubocop       # style
```

Test against a specific Rails version:

```bash
$ bundle exec appraisal install
$ BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rspec
$ BUNDLE_GEMFILE=gemfiles/rails_8_1_sprockets.gemfile bundle exec rspec
```

### Repo layout

```
swal_rails/
├── app/                           # Engine: helpers, views, assets
├── lib/
│   ├── swal_rails.rb              # entrypoint + Engine + Railtie
│   ├── swal_rails/configuration.rb
│   └── generators/
│       ├── install/               # bin/rails g swal_rails:install
│       └── locales/               # bin/rails g swal_rails:locales
├── vendor/javascript/sweetalert2/ # pinned SA2 v11.26.24 (MIT)
├── spec/
│   └── dummy/                     # minimal Rails app for system tests
├── Appraisals                     # Rails 7.0 → 8.1 + sprockets variant
└── gemfiles/                      # per-version lockfiles (generated)
```

---

## 🤝 Contributing

Bug reports and pull requests welcome on GitHub at
<https://github.com/Metalzoid/swal_rails>.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Make sure tests and RuboCop pass (`bundle exec rspec && bundle exec rubocop`)
4. Push (`git push origin my-new-feature`)
5. Open a Pull Request

---

## 🙏 Credits & license

This gem bundles [SweetAlert2](https://sweetalert2.github.io/) by Tristan
Edwards, Limon Monte and contributors, distributed under the MIT License. The
full license is included at `vendor/javascript/sweetalert2/LICENSE`.

`swal_rails` itself is released under the [MIT License](LICENSE.txt).

<div align="center">

Built with 🍬 by [Metalzoid](https://github.com/Metalzoid)

</div>
