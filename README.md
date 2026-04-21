<div align="center">

# 🍬 swal_rails

**SweetAlert2 v11 for Rails 7+ — batteries included.**

First-class support for **Importmap**, **jsbundling**, and **Sprockets**, with a
Stimulus controller, auto-wired flash messages, Turbo confirm replacement,
Ruby view helpers, and full I18n. Everything is configurable.

[![CI](https://github.com/Metalzoid/swal_rails/actions/workflows/main.yml/badge.svg)](https://github.com/Metalzoid/swal_rails/actions)
[![Gem Version](https://badge.fury.io/rb/swal_rails.svg)](https://rubygems.org/gems/swal_rails)
[![Ruby](https://img.shields.io/gem/ruby-version/swal_rails?label=ruby)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/gem/dv/swal_rails/railties?label=rails)](https://rubyonrails.org/)
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
  - [Multi-step confirmations](#multi-step-confirmations)
  - [Stimulus controller](#stimulus-controller)
  - [Ruby view helpers](#ruby-view-helpers)
  - [Programmatic JS](#programmatic-js)
- [I18n](#-i18n)
- [Accessibility](#-accessibility)
- [Security & CSP](#-security--csp)
- [Themes](#-themes)
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
- 🔒 **CSP-friendly** — `swal_tag(..., nonce: true)` propagates the per-request nonce.
- 🌍 **I18n ready** — `en` / `fr` locales shipped, override freely.
- ♿ **Accessibility** — honors `prefers-reduced-motion`, preserves ARIA & focus trap.
- 🧩 **Engine-based** — zero monkey-patching, follows Rails Engine conventions.

---

## 🔧 Compatibility

Tested on every combination of Ruby and Rails listed below via the
[Appraisal](https://github.com/thoughtbot/appraisal) gem:

|         | Rails 7.2 | Rails 8.0 | Rails 8.1.3 | Rails 8.1.3 + Sprockets |
| ------- | :-------: | :-------: | :---------: | :---------------------: |
| Ruby 3.2|     ✅    |     ✅    |      ✅     |            ✅           |
| Ruby 3.3|     ✅    |     ✅    |      ✅     |            ✅           |
| Ruby 3.4|     ✅    |     ✅    |      ✅     |            ✅           |
| Ruby 3.5|     ✅    |     ✅    |      ✅     |            ✅           |
| Ruby 4.0|     —     |     ✅    |      ✅     |            ✅           |

> **Requirements:** Ruby **≥ 3.2** (tested up to **4.0**), Rails **≥ 7.2** (tested up to **8.1.3**), Turbo recommended.

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

Arrays are expanded into one popup per message — handy for model errors:

```ruby
flash[:alert] = @post.errors.full_messages  # ["Title can't be blank", "Body is too short"]
# → two separate Swals, one per message
```

Need to override the per-key defaults for a single request? Assign a **Hash**
instead of a String — its keys flow straight into `Swal.fire` and shadow
`flash_map[key]`:

```ruby
flash[:notice] = { text: "Deployed!", icon: "rocket", timer: 5000, toast: true }
# → ignores flash_map[:notice], fires a 5-second rocket toast
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

Pass a **Hash** instead of a string to carry full SA2 options:

```erb
<%= button_to "Delete", post_path(@post), method: :delete, data: {
      turbo_confirm: { icon: "error", title: "Really?", confirmButtonText: "Nuke" }
    } %>
```

Rails JSON-encodes the Hash into the attribute; the runtime parses it back
and treats it as a full options object (same thing works with
`data-swal-confirm`).

---

### `data-swal-confirm` attribute

If you don't want to override Turbo globally, opt-in per element:

```erb
<%= link_to "Archive", archive_path,
      data: { swal_confirm: "Archive this item?", swal_icon: "warning" } %>
```

Supported data attributes:

| Attribute                          | Maps to                |
| ---------------------------------- | ---------------------- |
| `data-swal-confirm`                | `text` / title prompt  |
| `data-swal-title`                  | `title`                |
| `data-swal-text`                   | `text`                 |
| `data-swal-icon`                   | `icon`                 |
| `data-swal-confirm-text`           | `confirmButtonText`    |
| `data-swal-cancel-text`            | `cancelButtonText`     |
| `data-swal-options` *(JSON)*       | full SA2 options (wins over the above) |

Use `data-swal-options` when you need anything beyond the shortcuts — it
accepts any SweetAlert2 option:

```erb
<%= button_to "Delete", post_path(@post), method: :delete, data: {
      swal_confirm: "Danger",
      swal_options: { icon: "error", iconColor: "#ff0000", confirmButtonText: "Nuke" }.to_json
    } %>
```

---

### Multi-step confirmations

For destructive flows (account deletion, legal opt-ins, irreversible
actions), chain several popups via `data-swal-steps`. Each step only
fires if the previous one was **confirmed** — any Cancel or Esc aborts
the whole cascade, and the original click/submit never reaches the
server:

```erb
<%= button_to "Delete account", account_path, method: :delete, data: {
      swal_steps: [
        { title: "Delete your account?", icon: "warning" },
        { title: "This cannot be undone", icon: "error" },
        { title: "Type DELETE to confirm", input: "text" }
      ].to_json
    } %>
```

Every step is a full SweetAlert2 options Hash — override the default
icon, buttons, timer, `input:` type, anything SA2 accepts. The per-step
defaults (`showCancelButton: true`, `focusCancel: true`, `icon: "warning"`)
are merged in first and can be replaced key-by-key.

#### Conditional branching (`onConfirmed` / `onDenied`)

Add a Deny button (`showDenyButton: true`) to get a three-way choice, and
attach a nested sub-chain to either outcome:

```erb
<%= button_to "Delete or disable?", account_path, method: :delete, data: {
      swal_steps: [
        {
          title: "Delete or just disable?",
          icon: "question",
          showDenyButton: true,
          confirmButtonText: "Delete forever",
          denyButtonText:    "Disable for 30 days",
          onDenied: [
            { title: "Confirm disable", icon: "info" }
          ]
        }
      ].to_json
    } %>
```

Semantic rules, per step:

| SA2 result    | Behavior |
| ------------- | -------- |
| `isDismissed` | Abort the entire chain; action does not fire |
| `isConfirmed` | Run `onConfirmed` sub-chain if present (replaces remainder); else continue linearly |
| `isDenied`    | Run `onDenied` sub-chain if present (its result decides); else abort |

Sub-chains are recursive — they're just nested arrays of steps.

Under `confirm_mode = :turbo_override` (or `:both`), passing a JSON array
to `data-turbo-confirm` works the same way:

```erb
<%= button_to "Delete", account_path, method: :delete, data: {
      turbo_confirm: [
        { title: "Really?" },
        { title: "Really really?" }
      ]
    } %>
```

From Ruby, the view helper `swal_chain_tag` fires a chain inline on page
load (same CSP nonce and XSS hardening as `swal_tag`):

```erb
<%= swal_chain_tag([
      { title: "Welcome back" },
      { title: "Accept updated terms?" }
    ]) %>
```

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

Available actions: `fire`, `confirm`, `chain`. The `chain` action reads
`data-swal-steps-value` (same shape as `data-swal-steps`) and submits the
enclosing form if every step resolves confirmed.

---

### Ruby view helpers

Fire a one-shot popup directly from a view:

```erb
<%= swal_tag(title: "Welcome back!", icon: "info", timer: 2000) %>
```

Under a strict Content Security Policy, pass `nonce: true` — Rails fills in
the per-request nonce so the inline `<script>` survives the policy:

```erb
<%= swal_tag({ title: "Welcome back!" }, nonce: true) %>
```

> **Heads-up:** the emitted tag is `<script type="module">` with a bare
> `import Swal from "sweetalert2"`. That resolves via Importmap (or any
> shim that processes import maps). On a pure esbuild/webpack setup with
> no importmap tag on the page, prefer the Stimulus controller or call
> `window.Swal.fire(...)` from your bundle instead.

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

## 🔒 Security & CSP

### XSS safety

All strings flowing through the Ruby helpers are hardened against the usual
breakout sequences:

- **`swal_tag`** runs the serialized options through `ERB::Util.json_escape`,
  which neutralizes `</script>`, `<!--`, U+2028 and U+2029 before they reach
  the inline `<script>` body.
- **`swal_config_meta_tag`** and **`swal_flash_meta_tag`** emit `<meta>`
  attributes, which Rails HTML-escapes automatically; the JS runtime feeds
  messages to SweetAlert2's `text:` option (not `html:`), so flash payloads
  are rendered as text even if they contain HTML.

> ⚠️ **Hash-form overrides bypass the `text:` safety net.** When you pass a
> Hash to `flash[key]`, `data-turbo-confirm`, `data-swal-confirm`, or
> `data-swal-options`, its keys flow straight into `Swal.fire`. Using
> `html:`, `iconHtml:`, or `footer:` with untrusted input is an XSS —
> SweetAlert2 renders those as raw HTML by design. Rule of thumb: if the
> value is user-controlled, keep the String form (or the `text:` key).

### Content Security Policy

Meta tags carry no script and need no nonce. For the inline helper:

```erb
<%= swal_tag({ title: "Saved" }, nonce: true) %>
```

When ActionView's CSP helper is available, Rails substitutes the per-request
nonce; otherwise `nonce: true` is silently dropped so the tag stays valid on
apps without a configured CSP.

> **SweetAlert2 + strict `style-src`** — SA2 injects styles via JavaScript.
> Under `style-src 'self'` with no `'unsafe-inline'`, the popups won't be
> styled. Either ship SA2's CSS via your normal stylesheet (the gem vendors
> `sweetalert2.css`) or allow a style nonce for the inserted tags.

---

## 🎭 Themes

The six official SweetAlert2 themes are vendored alongside the default
stylesheet — pick one, load it in your layout, and set the
`data-swal2-theme` attribute to activate it.

| Theme | File |
| --- | --- |
| Bootstrap 4 | `sweetalert2/themes/bootstrap-4.css` |
| Bootstrap 5 | `sweetalert2/themes/bootstrap-5.css` |
| Borderless | `sweetalert2/themes/borderless.css` |
| Bulma | `sweetalert2/themes/bulma.css` |
| Material UI | `sweetalert2/themes/material-ui.css` |
| Minimal | `sweetalert2/themes/minimal.css` |

### Importmap / jsbundling (apps that load their own CSS)

```erb
<%# app/views/layouts/application.html.erb %>
<%= stylesheet_link_tag "sweetalert2/themes/bootstrap-5" %>
<body data-swal2-theme="bootstrap-5">
```

### Sprockets

```css
/* app/assets/stylesheets/application.css */
*= require sweetalert2/themes/bootstrap-5
```

`bootstrap-5` and `material-ui` ship both a light and a dark variant
baked into the same file — set `data-swal2-theme="bootstrap-5-dark"` or
`"material-ui-dark"` to opt into dark mode.

> **OS-driven dark mode?** Hook the attribute to `prefers-color-scheme`
> with a one-liner:
> ```js
> document.body.dataset.swal2Theme =
>   matchMedia("(prefers-color-scheme: dark)").matches
>     ? "bootstrap-5-dark" : "bootstrap-5"
> ```

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
$ bundle exec rspec         # 47 examples, real headless Chromium (Cuprite)
$ bundle exec rubocop       # style
```

Test against a specific Rails version:

```bash
$ bundle exec appraisal install
$ BUNDLE_GEMFILE=gemfiles/rails_7_2.gemfile bundle exec rspec
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
├── Appraisals                     # Rails 7.2 → 8.1 + sprockets variant
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
