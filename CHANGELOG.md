# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-04-19

### Added
- Rails Engine with multi-mode asset delivery (importmap, jsbundling, sprockets).
- `SwalRails::Configuration` with per-flash-key mapping and four confirm modes
  (`:off`, `:data_attribute`, `:turbo_override`, `:both`).
- JS runtime: bootstraps `Swal.mixin`, installs confirm handler, auto-fires flash messages.
- Stimulus controller `swal` with `fire` and `confirm` actions.
- View helpers: `swal_rails_meta_tags`, `swal_config_meta_tag`, `swal_flash_meta_tag`, `swal_tag`.
- Generators: `swal_rails:install` (with `--assets` flag) and `swal_rails:locales`.
- I18n: `en` and `fr` locales.
- a11y: respect for `prefers-reduced-motion`.
- Bundled SweetAlert2 v11.26.24 under MIT license.
