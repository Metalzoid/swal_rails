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
- [Reference](#-reference)
  - [`SwalRails.configure`](#swalrailsconfigure)
  - [View helpers](#view-helpers)
  - [Data attributes](#data-attributes)
  - [Stimulus controller reference](#stimulus-controller-reference)
  - [JS runtime](#js-runtime)
  - [Generators](#generators)
  - [Flash value shapes](#flash-value-shapes)
  - [Chain semantics](#chain-semantics)
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
- 🔔 **Auto-wired flash** — `flash[:notice]` / `flash[:alert]` → toast, stackable, fully mappable per key.
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

> **During the beta**, pin the prerelease explicitly:
> ```ruby
> gem "swal_rails", "0.3.1.beta1"
> ```
> or install globally with `gem install swal_rails --pre`. Bundler ignores prereleases unless you ask for one.

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
  config.flash_map[:notice]  = { icon: "success", toast: true, position: "top-end", timer: 3000 }
  config.flash_map[:success] = { icon: "success", toast: true, position: "top-end", timer: 3000 }
  config.flash_map[:alert]   = { icon: "error",   toast: true, position: "top-end", timer: 4000 }
  config.flash_map[:error]   = { icon: "error",   toast: true, position: "top-end", timer: 4000 }
  config.flash_map[:warning] = { icon: "warning", toast: true, position: "top-end", timer: 4000 }
  config.flash_map[:info]    = { icon: "info",    toast: true, position: "top-end", timer: 3000 }

  # ─── Multi-entry flash playback ─────────────────────────────────────
  config.flash_array_mode  = :sequential  # :sequential | :stacked
  config.flash_stack_delay = 500          # ms between stacked toasts

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
flash[:notice] = "Profile updated"   # → success toast top-right
flash[:alert]  = "Could not save"    # → error toast top-right (since 0.3.1.beta2)
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

#### Multi-entry playback: sequential vs stacked

When more than one flash entry is set in a single request — either through an
array of messages under one key, or multiple distinct keys — the runtime
picks one of two playback modes (configurable via `config.flash_array_mode`):

| Mode           | Behavior |
| -------------- | -------- |
| `:sequential`  | **(default)** Each Swal fires only after the previous one closes — chained via Promise callbacks. Predictable but slow on long lists. |
| `:stacked`     | All entries fire in parallel into a fixed top-right container, stacking vertically. Each appears `flash_stack_delay` ms after the previous (default 500ms), then runs its own timer independently. Any `toast: false` entry is forced to toast in this mode. |

#### `swal_flash` helper (per-request override)

For one-off overrides without touching the global config, use `swal_flash`
from controllers or views:

```ruby
# Pile up validation errors as a stack of toasts with a quicker 300ms cadence
swal_flash :alert, @post.errors.full_messages, mode: :stacked, delay: 300

# Same mode but over flash.now (for `render`, not `redirect_to`)
swal_flash :alert, "Form incomplete", now: true

# Extra SA2 options are merged into every entry
swal_flash :notice, "Deployed!", icon: "rocket", timer: 5000
```

Signature: `swal_flash(key, messages, mode: nil, delay: nil, now: false, **options)`.
`mode:` and `delay:` are stored on the flash entry as reserved `_arrayMode` /
`_stackDelay` meta-keys, extracted by the JS runtime before the options are
handed to `Swal.fire` — they never leak into SA2.

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

## 📘 Reference

Complete, at-a-glance specification of every public surface the gem
exposes. The sections above give narrative walk-throughs — this section
is the lookup table.

### `SwalRails.configure`

```ruby
SwalRails.configure { |config| ... }       # block form, yields Configuration
SwalRails.configuration                    # reader — memoized, safe to mutate
SwalRails.reset_configuration!             # resets to defaults (test fixture helper)
```

#### Configuration attributes

| Attribute                | Type    | Default            | Description |
| ------------------------ | ------- | ------------------ | ----------- |
| `confirm_mode`           | Symbol  | `:data_attribute`  | Routing of confirm dialogs — see values below. Validated: assignment with any other value raises `ArgumentError`. Strings are coerced to symbols. |
| `flash_keys_as_meta`     | Boolean | `true`             | When `false`, `swal_flash_meta_tag` returns `nil` — useful to opt out without removing the `swal_rails_meta_tags` call from the layout. |
| `respect_reduced_motion` | Boolean | `true`             | When the OS reports `prefers-reduced-motion: reduce`, the gem empties SA2's `showClass` / `hideClass` to suppress animations. |
| `expose_window_swal`     | Boolean | `true`             | When `true`, `window.Swal` is set to the mixed-in `Swal` instance after boot (useful for console debugging and inline scripts). |
| `default_options`        | Hash    | see below          | Merged into **every** `Swal.fire(...)` call via `Swal.mixin(...)`. |
| `flash_map`              | Hash    | see below          | Flash-key → SA2 options mapping. Keys normalized to symbols. Non-Hash assignment raises `ArgumentError`. |
| `flash_array_mode`       | Symbol  | `:sequential`      | How multi-entry flash payloads are played: `:sequential` (one at a time, waits for close) or `:stacked` (all in parallel, stacked top-right). Validated. |
| `flash_stack_delay`      | Integer | `500`              | Milliseconds between each toast's appearance in `:stacked` mode. |
| `i18n_scope`             | String  | `"swal_rails"`     | I18n scope used to look up `confirm_button_text`, `cancel_button_text`, `deny_button_text`, `close_button_aria_label`. Non-string values are coerced. |

`confirm_mode` accepted values:

| Value              | Behavior |
| ------------------ | -------- |
| `:off`             | No Turbo override, no data-attribute listener. Use `Swal` manually. |
| `:data_attribute`  | **(default)** intercept clicks/submits on `[data-swal-confirm]` and `[data-swal-steps]`. Does not touch Turbo. |
| `:turbo_override`  | Replaces `Turbo.setConfirmMethod` globally. `data-turbo-confirm` attributes open SA2 modals. |
| `:both`            | Enables both mechanisms — useful for mixed codebases migrating over. |

`default_options` default:

```ruby
{ buttonsStyling: true, reverseButtons: false, focusConfirm: true, returnFocus: true }
```

`flash_map` default (per key, all overridable):

```ruby
{
  notice:  { icon: "success", toast: true, position: "top-end", timer: 3000, timerProgressBar: true, showConfirmButton: false },
  success: { icon: "success", toast: true, position: "top-end", timer: 3000, timerProgressBar: true, showConfirmButton: false },
  alert:   { icon: "error",   toast: true, position: "top-end", timer: 4000, timerProgressBar: true, showConfirmButton: false },
  error:   { icon: "error",   toast: true, position: "top-end", timer: 4000, timerProgressBar: true, showConfirmButton: false },
  warning: { icon: "warning", toast: true, position: "top-end", timer: 4000, timerProgressBar: true, showConfirmButton: false },
  info:    { icon: "info",    toast: true, position: "top-end", timer: 3000, timerProgressBar: true, showConfirmButton: false }
}
```

> 💡 **Prefer a modal for errors?** Override in your initializer:
> `config.flash_map[:alert] = { icon: "error", toast: false }`.

#### `to_client_payload` (internal, read-only)

Serialization contract consumed by the JS runtime via the
`<meta name="swal-config">` tag. Returns:

```ruby
{
  confirmMode:          Symbol,
  respectReducedMotion: Boolean,
  exposeWindowSwal:     Boolean,
  defaultOptions:       Hash,
  flashMap:             Hash,
  flashArrayMode:       Symbol,  # :sequential | :stacked
  flashStackDelay:      Integer, # ms
  i18n:                 Hash     # only keys whose translation is present
}
```

---

### View helpers

All helpers are injected into both `ActionController::Base` and
`ActionView::Base` by the engine; they are available in every view and
in every controller-side rendering context.

| Helper                             | Returns                                   | Description |
| ---------------------------------- | ----------------------------------------- | ----------- |
| `swal_rails_meta_tags`             | `ActiveSupport::SafeBuffer`               | Emits `swal_config_meta_tag` + `swal_flash_meta_tag` joined with `"\n"`. Call once, in `<head>`. |
| `swal_config_meta_tag`             | `ActiveSupport::SafeBuffer`               | Emits `<meta name="swal-config" content="…JSON…">` with the serialized `SwalRails.configuration.to_client_payload`. |
| `swal_flash_meta_tag`              | `ActiveSupport::SafeBuffer` or `nil`      | Emits `<meta name="swal-flash" content="…JSON…">` if `flash_keys_as_meta` is enabled **and** the current `flash` is non-empty; otherwise returns `nil`. |
| `swal_tag(options, html_options)`  | `ActiveSupport::SafeBuffer`               | Inline `<script type="module">` firing `Swal.fire(options)` once. Options are JSON-escaped to neutralize `</script>`, `<!--`, U+2028, U+2029. |
| `swal_chain_tag(steps, html_options)` | `ActiveSupport::SafeBuffer`            | Inline `<script type="module">` firing `chainDialogs(Swal, steps)`. `steps` is an Array of Hashes (single Hash is auto-wrapped). Same escape hardening as `swal_tag`. |

#### `html_options` (for `swal_tag` / `swal_chain_tag`)

- `nonce: true` → propagates the per-request CSP nonce (when Rails
  exposes `content_security_policy_nonce`). Silently dropped when no CSP
  helper is configured, so the helper stays safe in apps without CSP.
- Any other key is forwarded to `javascript_tag` as `<script>`
  attributes.

The default `type` is `"module"` — override with `html_options = { type: "text/javascript" }` if you need a classic script.

> ⚠️ The emitted `<script type="module">` contains bare imports
> (`import Swal from "sweetalert2"`). These resolve via Importmap; in a
> pure esbuild/webpack setup with no importmap tag on the page, call
> `window.Swal.fire(...)` from your bundle instead.

---

### Data attributes

All attributes are read from the element's `dataset`. Values carry through `button_to`, `link_to`, `form_with`, and raw HTML equally.

#### Single-step confirm (`data-swal-confirm`)

| Attribute                 | Accepts                      | Maps to (SA2 option) |
| ------------------------- | ---------------------------- | -------------------- |
| `data-swal-confirm`       | String **or** JSON object *or* JSON array | message (String) → `text`; Object → full SA2 options (overrides all shortcuts); Array → multi-step chain (see below) |
| `data-swal-title`         | String                       | `title` |
| `data-swal-text`          | String                       | `text` |
| `data-swal-icon`          | String (`"warning"`, `"error"`, …) | `icon` (default `"warning"`) |
| `data-swal-confirm-text`  | String                       | `confirmButtonText` |
| `data-swal-cancel-text`   | String                       | `cancelButtonText` |
| `data-swal-options`       | JSON Object (stringified)    | Full SA2 options — **wins over** all shortcuts and over the JSON object form of `data-swal-confirm` |

Merge order (later wins):

```
defaults → data-swal-* shortcuts → JSON object in data-swal-confirm → data-swal-options
```

#### Multi-step chain (`data-swal-steps`)

| Attribute                 | Accepts                                | Behavior |
| ------------------------- | -------------------------------------- | -------- |
| `data-swal-steps`         | JSON Array of step Hashes (stringified) | Runs the chain. Per-step defaults `{ showCancelButton: true, focusCancel: true, icon: "warning" }` are merged first and can be overridden key-by-key. Every step is a full SA2 options Hash plus the optional `onConfirmed` / `onDenied` sub-chain keys. |

Both attributes coexist — if `data-swal-steps` is present and non-empty, it takes precedence over `data-swal-confirm`.

#### Turbo `data-turbo-confirm`

When `confirm_mode` is `:turbo_override` or `:both`, `data-turbo-confirm` accepts:

| Form    | Behavior |
| ------- | -------- |
| String  | SA2 popup with the string as `text`. |
| Hash (JSON-encoded by Rails) | Full SA2 options. |
| Array (JSON-encoded by Rails) | Multi-step chain — same shape as `data-swal-steps`. |

---

### Stimulus controller reference

Registered under the identifier `"swal"`.

#### Values

| Value         | Type   | Default | Used by |
| ------------- | ------ | ------- | ------- |
| `optionsValue` | Object | `{}`    | `fire`, `confirm` |
| `stepsValue`   | Array  | `[]`    | `chain` |

#### Actions

| Action    | Target behavior |
| --------- | --------------- |
| `fire`    | Fires `Swal.fire(optionsValue)`. Calls `preventDefault()` on the event if the element is `<a>` or `<button>`. Returns the SA2 promise. |
| `confirm` | Fires `Swal.fire({ showCancelButton: true, focusCancel: true, ...optionsValue })`. On `isConfirmed`, calls `requestSubmit()` (fallback `submit()`) on the enclosing form. |
| `chain`   | Runs `chainDialogs(Swal, stepsValue)`. On resolved `true`, calls `requestSubmit()` / `submit()` on the enclosing form. Returns the boolean. |

Example:

```erb
<button data-controller="swal"
        data-action="click->swal#chain"
        data-swal-steps-value='[{"title":"Sure?"},{"title":"Really?"}]'>
  Proceed
</button>
```

---

### JS runtime

#### Entry point

```js
import "swal_rails"              // installs confirm + flash handlers
```

Expected in your JS entrypoint (e.g. `app/javascript/application.js`).

#### Re-exports

```js
import Swal from "sweetalert2"                            // SA2, re-exported as default from swal_rails
import { Swal } from "swal_rails"                         // named re-export (same instance)
import { chainDialogs, CHAIN_DEFAULTS } from "swal_rails/chain"
import { installConfirm } from "swal_rails/confirm"       // for custom boot sequences
import { installFlash } from "swal_rails/flash"           // same
```

#### `chainDialogs(Swal, steps)`

```ts
chainDialogs(Swal: typeof import("sweetalert2"), steps: Array<StepOptions>): Promise<boolean>
```

Returns `true` iff a complete path through the chain was confirmed. `steps` may be empty (resolves `true` immediately). Non-array input resolves `true` as well.

`StepOptions` is any valid SA2 options Hash, plus the two chain-only keys:

| Key            | Type                | Effect |
| -------------- | ------------------- | ------ |
| `onConfirmed`  | `Array<StepOptions>` | On `isConfirmed`, run this sub-chain and adopt its boolean result (replaces the remainder of the current chain). |
| `onDenied`     | `Array<StepOptions>` | On `isDenied` (requires `showDenyButton: true`), run this sub-chain and adopt its boolean result. Without this key, `isDenied` aborts the chain. |

#### Events

| Event name         | Target     | `event.detail` | When |
| ------------------ | ---------- | -------------- | ---- |
| `swal-rails:ready` | `document` | `{ Swal, config }` | Fired once per page lifetime after the first successful boot (not per Turbo navigation). |

#### Meta-tag contract

| Meta name     | Payload | Read by |
| ------------- | ------- | ------- |
| `swal-config` | `to_client_payload` JSON | Runtime boot — mixin, confirm handler, flash handler. Once per page. |
| `swal-flash`  | Array of `{ key, options }` | Flash runtime — re-read on every `turbo:load`. |

Flash entries are `{ key: "notice", options: { text: "..." } }` for string values, or `{ key: "notice", options: {...user hash...} }` for Hash values. Arrays in `flash[key]` are expanded into one entry per element.

---

### Generators

#### `bin/rails g swal_rails:install`

| Flag                      | Type    | Default           | Values |
| ------------------------- | ------- | ----------------- | ------ |
| `--mode`                  | String  | `auto`            | `auto`, `importmap`, `jsbundling`, `sprockets` |
| `--confirm_mode`          | String  | `data_attribute`  | `off`, `data_attribute`, `turbo_override`, `both` — baked into the generated initializer |
| `--skip_layout`           | Boolean | `false`           | When set, does not inject `<%= swal_rails_meta_tags %>` into `app/views/layouts/application.html.erb` |

`--mode=auto` detection order:
1. `config/importmap.rb` present → `importmap`
2. `package.json` present → `jsbundling`
3. fallback → `sprockets`

Per-mode side effects:

- **importmap**: appends `pin "sweetalert2", to: "sweetalert2.esm.all.js"` and `pin "swal_rails", to: "swal_rails/index.js"` to `config/importmap.rb`; appends `import "swal_rails"` to `app/javascript/application.js`.
- **jsbundling**: runs `yarn add sweetalert2@<pinned>` or `npm install sweetalert2@<pinned>` (based on the lockfile present); appends `import "swal_rails"` to `app/javascript/application.js`.
- **sprockets**: appends `//= link sweetalert2.js` and `//= link sweetalert2.css` to `app/assets/config/manifest.js`.

All append operations are idempotent — running the generator twice is safe.

#### `bin/rails g swal_rails:locales`

No flags. Copies `config/locales/swal_rails.en.yml` and `swal_rails.fr.yml` from the gem into your app's `config/locales/`.

---

### Flash value shapes

| Value type | Rendered as |
| ---------- | ----------- |
| `String`   | `{ text: value }` — safe by default (SA2 renders via `text:`, no HTML injection). |
| `Hash`     | Full SA2 options, **shadows** `flash_map[key]`. Any SA2 key is accepted (icon, timer, input, html, iconHtml, …). |
| `Array`    | Expanded into one entry per element. Strings become `{ text: elem }`, Hashes pass through verbatim. |
| `nil` / `""` / `blank?` | Skipped. |

Key normalization: Hash keys are `symbolize_keys`-ed before serialization, so `flash[:notice] = { "text" => "..." }` and `flash[:notice] = { text: "..." }` are equivalent.

> ⚠️ **Hash overrides bypass the `text:` safety net.** Using `html:`, `iconHtml:`, or `footer:` with untrusted input is an XSS — SweetAlert2 renders those as raw HTML by design. Rule of thumb: if the value is user-controlled, keep the String form.

---

### Chain semantics

Single source of truth for every chain-aware entry point (`data-swal-steps`, `data-turbo-confirm` with an array, Stimulus `chain` action, `swal_chain_tag`, direct `chainDialogs` call).

Per step:

| SA2 result    | Behavior |
| ------------- | -------- |
| `isDismissed` (×, Esc, backdrop) | Abort the current chain → `false`. Outer chain (if this was a sub-chain) also terminates with `false`. |
| `isConfirmed` | If `onConfirmed: [...]` is defined, run it recursively and **replace** the remainder of the current chain with its result. Else continue linearly. |
| `isDenied` (requires `showDenyButton: true`) | If `onDenied: [...]` is defined, run it recursively and adopt its result. Else abort → `false`. |

Return rules:

- An empty or non-array `steps` input resolves `true` immediately.
- A chain resolves `true` iff it ran to completion along a path without any dismiss or unbranched deny.
- Sub-chains inherit the same per-step defaults (`showCancelButton: true`, `focusCancel: true`, `icon: "warning"`).
- `onConfirmed` / `onDenied` keys are stripped before being passed to `Swal.fire`, so they never leak into the SA2 popup options.

Callback contract for Turbo override: the chain's final `Promise<boolean>` is what `Turbo.setConfirmMethod` receives — `false` cancels the navigation / form submit, `true` proceeds.

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
