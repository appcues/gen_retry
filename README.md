# GenRetry

[![Build Status](https://circleci.com/gh/appcues/gen_retry.svg?style=svg)](https://circleci.com/gh/appcues/gen_retry)
[![Hex.pm Version](http://img.shields.io/hexpm/v/gen_retry.svg?style=flat)](https://hex.pm/packages/gen_retry)

GenRetry provides utilities for retrying Elixir functions,
with configurable delay and backoff characteristics.

## Examples

```elixir
my_background_function = fn ->
  :ok = try_to_send_tps_reports()
end
GenRetry.retry(my_background_function, retries: 10, delay: 10_000)
```

```elixir
my_future_function = fn ->
  {:ok, val} = get_val_from_flaky_network_service()
  val
end
t = GenRetry.Task.async(my_future_function, retries: 3)
my_val = Task.await(t)  # may raise exception
```

## [Full Documentation](http://hexdocs.pm/gen_retry/GenRetry.html)

[Full gen_retry documentation is available on
Hexdocs.pm.](http://hexdocs.pm/gen_retry/GenRetry.html)

## Changelog and Contributors

[CHANGELOG.md](CHANGELOG.md) is a record of contributions and
releases. Thanks so much to everyone who's submitted patches!

## Authorship and License

GenRetry is copyright 2016-2021 Appcues, Inc.

GenRetry is released under the [MIT License](LICENSE.txt).
