# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0] - 2026-05-28

### Added
- **Turbo Stream action `swal`** — `Turbo.StreamActions.swal` is registered at
  boot, reading a JSON payload from the `<template>` element and calling
  `Swal.fire()`. Covers `format.turbo_stream` responses, which never fire
  `turbo:load` / `turbo:render` and were therefore silently ignored by the
  existing meta-tag flash path.
  Closes [#27](https://github.com/Metalzoid/swal_rails/issues/27).
- **`turbo_stream.swal(options)`** — emits a `<turbo-stream action="swal">`
  tag with free-form SweetAlert2 options.
- **`turbo_stream.swal_flash(key, message, **overrides)`** — flash-map-aware
  shortcut; maps the key through `SwalRails.configuration.flash_map` and
  merges `text:` + any overrides.
- **npm exports entry `swal_rails/stream`** — added to `package.json` exports
  map for jsbundling users.

## [0.5.0] - 2026-05-27

### Added
- **npm companion package** (`swal_rails` on npm). The install generator now runs
  `yarn add swal_rails@<version>` (or `npm install`) in jsbundling mode, placing
  the gem's JS runtime in `node_modules/swal_rails` so esbuild / webpack / vite
  can resolve `import "swal_rails"` as a bare specifier — with no bundler
  config required. All sub-paths (`swal_rails/confirm`, `/flash`, `/chain`,
  `/controllers/swal_controller`) are covered via the package `exports` map.
  Closes [#24](https://github.com/Metalzoid/swal_rails/issues/24).
- **`rake npm:sync`** — copies JS files from `app/assets/javascripts/swal_rails/`
  into `npm/` and bumps `npm/package.json` version to match `SwalRails::VERSION`.
  Run before any npm publish.
- **`rake npm:publish`** — runs `npm:sync` then `npm publish --access public`.
- **`_persistent` flash option** — adding `_persistent: true` to a flash entry
  (via `swal_flash :key, msg, _persistent: true` or directly in `flash_map`)
  removes the auto-close timer and forces a visible close button, requiring
  manual dismissal.

### Fixed
- **Stacked flash clone timing** — `didRender` replaced by `willOpen` + `didOpen`
  for cloning SA2 popups into the stack container. The previous `timer: 1` could
  race the `setTimeout(0)` SA2 uses to schedule `didOpen`, leaving slots empty.
  Timer raised to 50 ms; the original popup is hidden via `willOpen` (opacity 0,
  pointer-events none) so the clone is the only visible element.
- **Stacked toast CSS scope** — SA2 scopes element rules under
  `div:where(.swal2-container)` (zero-specificity `:where()`). Clones rendered
  outside that container lost color, border-radius, and the close-button layout.
  Added explicit `div.swal2-popup`, `div.swal2-html-container`, and
  `button.swal2-close` rules in `index.css` that apply regardless of scope.
- **`install_jsbundling` generator** — previously only installed `sweetalert2`;
  now also installs `swal_rails` from the npm registry.

### Changed
- Release workflow (`.github/workflows/release.yml`) auto-publishes the npm
  package after every gem push via the `NPM_TOKEN` repository secret.

## [0.4.0] - 2026-05-03

### Added
- **`config.assets_mode`** (`:auto` default; also `:importmap`, `:jsbundling`, `:sprockets`). When set to a non-`:auto` value, the engine skips file-system sniffing at boot.
- **`config.precompile_strategy`** (`:all` default; `:minimal` opt-in). Setting it to `:minimal` ships only the sweetalert2 variant matching the resolved `assets_mode` (and drops the optional theme files), saving ~700 KB of precompiled assets in `public/assets/`.
- **`SwalRails::AssetManifest`** module that computes the precompile list. Pure / side-effect-free; covered by spec.

### Changed
- The `swal_rails.assets` initializer now runs `after: :load_config_initializers` so it can read user-supplied `config.assets_mode` / `config.precompile_strategy`. Default behaviour is unchanged for hosts that don't configure either option.

### Deprecated
- **`swal_tag`** and **`swal_chain_tag`** view helpers. Both emit inline `<script type="module">` tags that fight CSP and add per-request nonce overhead; prefer the bundled Stimulus controller (`data-controller="swal"` + `data-action="click->swal#fire"`) or the `data-swal-confirm` / `data-swal-steps` attributes. Slated for removal in v1.0; calling either helper now logs an `ActiveSupport::Deprecation` warning.

## [0.3.4] - 2026-05-01

### Added
- Chain step DSL gains `inputExpected` / `inputExpectedError` for typed
  confirmations in JSON-delivered flows (`data-swal-steps`,
  `data-turbo-confirm` arrays, Stimulus `stepsValue`). The runtime injects
  an `inputValidator` that requires exact text (after trim), making "Type
  DELETE" steps enforceable without embedding JavaScript functions.

### Fixed
- Stacked flash toasts no longer render with the icon/title/content
  collapsed into a vertical block. SweetAlert2 only sets
  `popup.style.display = "grid"` at `didOpen`, but the stacked-mode runtime
  clones the popup at `didRender` (one lifecycle step earlier) so the
  inline display is missing. Outside SA2's `.swal2-container` the toast
  fell back to `display: block` and the `.swal2-toast` grid template never
  applied. The clone now pins `display: grid` itself, matching the
  geometry of standard toasts.

## [0.3.3] - 2026-04-25

### Added
- Boot-time initializer drift detection. The gem ships
  `SwalRails::INITIALIZER_VERSION`, the install template stamps
  `config.initializer_version = "<current>"`, and a Rails initializer
  hooked after `:load_config_initializers` logs a one-line warning when
  the user's stamp is missing or trails the gem's expected value. Includes
  the regenerate command in the message:
  `bin/rails g swal_rails:install --skip-layout --force`.
- `config.silence_initializer_warning` (Boolean, default `false`) opt-out
  for users who don't want to regenerate.

## [0.3.2] - 2026-04-25

First stable release on top of the `0.3.1.beta1` + `0.3.1.beta2`
prereleases. End users upgrading from `0.3.0` should read the
consolidated entry below.

### Added
- `config.flash_array_mode` (`:sequential` default | `:stacked`) — how a
  multi-entry flash payload is played. Sequential waits for each Swal to
  close before firing the next; stacked renders every toast in parallel in
  a fixed top-right container with a configurable delay between each
  appearance.
- `config.flash_stack_delay` (ms, default 500) — gap between stacked
  toasts in `:stacked` mode.
- `swal_flash(key, messages, mode:, delay:, now:, **options)` helper,
  available in both controllers and views. Lets a single call override the
  global mode/delay and merge extra SA2 options for the payload:
  `swal_flash :alert, @post.errors.full_messages, mode: :stacked, delay: 300`.
- Reserved meta-keys `_arrayMode` / `_stackDelay` on flash entry options,
  stripped by the JS runtime before being passed to `Swal.fire`.

### Changed
- `flash_map[:alert]` and `flash_map[:error]` now default to a toast
  (top-end, 4s, error icon) instead of a blocking modal. Every built-in
  flash key is a toast out of the box — more consistent and in line with
  how Rails apps typically use `flash[:alert]`. The old modal behavior is
  still opt-in: `config.flash_map[:alert] = { icon: "error", toast: false }`.
- `default_options` no longer ships with `focusConfirm: true` /
  `returnFocus: true`. Both are SA2's internal defaults already, so
  behavior is unchanged — but listing them explicitly made SA2 warn
  ("incompatible with toasts") on every toast fire. Generator template
  updated to match.
- Generator initializer comment for `:turbo_override` now mentions
  `Turbo.config.forms.confirm` (Turbo 8.1+) with a fallback to the legacy
  `setConfirmMethod`.
- Release workflow now publishes to RubyGems via [Trusted Publishing](https://guides.rubygems.org/trusted-publishing/) (OIDC), no long-lived API key.
- First public release on [RubyGems.org](https://rubygems.org/gems/swal_rails). Prior `0.x` tags lived on GitHub Packages only.

### Fixed
- Flash runtime also boots on `turbo:render`, not just `turbo:load`. Form
  submissions that render in place (`render :index, status:
  :unprocessable_entity` for `flash.now` payloads) trigger `turbo:render`
  but not `turbo:load`, so the `swal-flash` meta tag emitted in the new
  body never reached the runtime. The `data-swal-consumed` guard on the
  meta tag dedupes the double-fire on full navigations.
- Stacked-mode clones render at SA2's standard toast width (360px, capped
  at `calc(100vw - 2rem)`) instead of stretching to the full page. CSS on
  `#swal-rails-stack` mirrors SA2's `body.swal2-toast-shown .swal2-container`
  rules — necessary because the cloned popups live outside SA2's container
  hierarchy.
- Confirm `:turbo_override` / `:both` writes to `Turbo.config.forms.confirm`
  first (Turbo 8.1+) and falls back to the deprecated
  `Turbo.setConfirmMethod`. Silences the Turbo deprecation warning.

### Security
- `.gitignore` hardened preventively against `.env`, `master.key`,
  `config/credentials/*.key`, `*.pem`, `*.key`.
- Gemspec pins `allowed_push_host` to `https://rubygems.org` as a safety
  net against accidental push to other hosts.

## [0.3.1.beta2] - 2026-04-24

Prerelease snapshot — superseded by [0.3.2].

## [0.3.1.beta1] - 2026-04-21

Prerelease snapshot — superseded by [0.3.2].

## [0.3.0] - 2026-04-21

### Added
- **Multi-step confirm chains** — `data-swal-steps='[{...}, {...}]'` (JSON array) runs each step sequentially and only proceeds with the original click/submit if every step is confirmed. Each step is a full SweetAlert2 options Hash, with per-step defaults (`showCancelButton`, `focusCancel`, `icon: "warning"`) merged in first.
- **Conditional branching** via `onConfirmed` / `onDenied` sub-chains on any step — opt in to a Deny button with `showDenyButton: true` to get a three-way choice; nested sub-chains are recursive. `isDismissed` always aborts.
- `data-turbo-confirm` (under `:turbo_override` / `:both`) now also accepts a JSON array, firing a chain via the Turbo override path.
- Stimulus controller gains a `chain` action reading `data-swal-steps-value`; submits the enclosing form when the chain resolves confirmed.
- Ruby view helper `swal_chain_tag(steps, html_options = {})` — symmetric with `swal_tag`, same `ERB::Util.json_escape` hardening and CSP nonce handling.

### Fixed
- `boot()` is now idempotent across `turbo:load` events: on Turbo-driven navigations the capture-phase click/submit listeners are installed exactly once for the page lifetime, instead of stacking one additional listener per navigation. Previously, after N Turbo visits a single `[data-swal-confirm]` click opened N cascading modals.
- Confirm → form submit path now calls `form.requestSubmit()` when available (falling back to `form.submit()`), so Turbo and UJS `submit` listeners stay in the loop.

### Security
- Documented the Hash-form escape hatch: when a Hash is assigned to `flash[key]`, `data-turbo-confirm`, `data-swal-confirm` or `data-swal-options`, its keys (notably `html:`, `iconHtml:`, `footer:`) flow unescaped into SweetAlert2. The String form keeps payloads in `text:` and remains XSS-safe by default.

## [0.2.1] - 2026-04-20

### Changed
- Release workflow now also triggers on push to `main`: when the version in `lib/swal_rails/version.rb` advances past the last `v*` tag, the workflow creates and pushes the tag, then runs the existing build / GitHub Release / GitHub Packages publish steps in the same job. Tag pushes keep working unchanged.

## [0.2.0] - 2026-04-20

### Added
- Per-request SA2 options via Hash values:
  - `flash[:notice] = { text: "…", icon: "rocket", timer: 5000 }` shadows `flash_map[:notice]`.
  - `data: { turbo_confirm: { icon: "error", title: "Really?" } }` (or `swal_confirm:`) — Rails JSON-encodes the Hash, the runtime parses it back and treats it as full SA2 options.
  - `data-swal-options='{…}'` on confirm triggers — full SA2 options escape hatch, wins over shortcut `data-swal-*` attributes.
- Flash array expansion: `flash[:alert] = @post.errors.full_messages` fires one Swal per message.
- CSP nonce support on `swal_tag`: pass `nonce: true` to have Rails substitute the per-request CSP nonce; silent fallback when no CSP helper is configured.
- Six official SweetAlert2 themes vendored under `vendor/stylesheets/sweetalert2/themes/` (bootstrap-4, bootstrap-5, borderless, bulma, material-ui, minimal). `bootstrap-5` and `material-ui` carry built-in dark variants via `data-swal2-theme="…-dark"`.
- `Sprockets::Rails` precompile allowlist now includes the ESM bundles, the Stimulus controller path, and all vendored themes — fixes `AssetNotPrecompiledError` on Sprockets host apps.

### Security
- `swal_tag` runs its options through `ERB::Util.json_escape` before interpolating them into the `<script>` body, neutralizing `</script>`, `<!--`, U+2028 and U+2029 — the four sequences that can break out of an inline script block.

### Fixed
- Global configuration no longer leaks between spec files (`swal_rails_spec.rb` mutated `confirm_mode` without restoring it, causing intermittent flakes in the system suite).

### Changed
- Flash meta-tag JSON shape: each entry is now `{key, options}` instead of `{key, message}`. Internal to the gem — no action required by consumers of the Ruby API.

## [0.1.0] - 2026-04-19

### Added
- Rails Engine with multi-mode asset delivery (importmap, jsbundling, sprockets).
- `SwalRails::Configuration` with per-flash-key mapping and four confirm modes
  (`:off`, `:data_attribute`, `:turbo_override`, `:both`).
- JS runtime: bootstraps `Swal.mixin`, installs confirm handler, auto-fires flash messages.
- Stimulus controller `swal` with `fire` and `confirm` actions.
- View helpers: `swal_rails_meta_tags`, `swal_config_meta_tag`, `swal_flash_meta_tag`, `swal_tag`.
- Generators: `swal_rails:install` (with `--mode` flag) and `swal_rails:locales`.
- I18n: `en` and `fr` locales.
- a11y: respect for `prefers-reduced-motion`.
- Bundled SweetAlert2 v11.26.24 under MIT license.
