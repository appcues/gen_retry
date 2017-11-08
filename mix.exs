defmodule GenRetry.Mixfile do
  use Mix.Project

  def project do
    [app: :gen_retry,
     description: description(),
     package: package(),
     version: "1.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
     deps: deps()]
  end

  defp description do
    ~S"""
    GenRetry provides utilities for retrying Elixir functions,
    with configurable delay and backoff characteristics.
    """
  end

  defp package do
    [
      maintainers: ["pete gamache", "Appcues"],
      licenses: ["MIT"],
      links: %{GitHub: "https://github.com/appcues/gen_retry"},
    ]
  end

  def application do
    [applications: [:logger, :exconstructor],
     mod: {GenRetry, []}]
  end

  defp deps do
    [
      {:exconstructor, "~> 1.0"},
      {:ex_doc, "~> 0.10.0", only: :dev},
      {:dialyxir, "~> 0.3", only: :dev},
      {:ex_spec, github: "appcues/ex_spec", tag: "1.1.0-elixir13", only: :test},
      {:excoveralls, "~> 0.5", only: :test},
    ]
  end
end

