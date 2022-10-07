defmodule GenRetry.Mixfile do
  use Mix.Project

  def project do
    [
      app: :gen_retry,
      description: description(),
      package: package(),
      version: "1.4.1",
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps()
    ]
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
      links: %{GitHub: "https://github.com/appcues/gen_retry"}
    ]
  end

  def application do
    [applications: [:logger, :exconstructor], mod: {GenRetry, []}]
  end

  defp deps do
    [
      {:mock, "~> 0.3.0", only: :test},
      {:exconstructor, "~> 1.0"},
      {:ex_doc, "~> 0.26.0", only: :dev},
      {:dialyxir, "~> 1.1", only: :dev},
      {:earmark, "~> 1.4", only: :dev},
      {:ex_spec, "~> 2.0.0", only: :test},
      {:excoveralls, "~> 0.5", only: :test}
    ]
  end
end
