# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
