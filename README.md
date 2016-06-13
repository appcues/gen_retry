# GenRetry

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
t = GenRetry.task(my_future_function, retries: 3)
my_val = Task.await(t)  # may raise exception
```


## [Full Documentation](http://hexdocs.pm/gen_retry/0.2.0/GenRetry.html)

[Full gen_retry documentation is available on
Hexdocs.pm.](http://hexdocs.pm/gen_retry/0.2.0/GenRetry.html)


## Authorship and License

GenRetry is copyright 2016 Appcues, Inc.

GenRetry is released under the
[MIT License](https://github.com/appcues/gen_retry/blob/master/LICENSE.txt).

