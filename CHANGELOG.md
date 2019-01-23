# Changelog

## 1.2.0

Added `on_success` and `on_failure` callbacks, raised minimum
Elixir version to 1.7, and added support for Elixir 1.8.
Thanks [@derekkraan](https://github.com/derekkraan)!

## 1.1.0

Added ability to specify custom logging module in config.

## 1.0.2

Elixir 1.4 compatibility.
Thanks [@wfgilman](https://github.com/wfgilman) and
[@JonRowe](https://github.com/JonRowe)!

## 1.0.1

Changed `:random.uniform` to `:rand.uniform` to silence deprecation
warnings.  Thanks [@amokan](https://github.com/amokan)!

## 1.0.0

Initial release.  Supports `GenRetry.retry/2` and
`GenRetry.Task.async/2`.

