defmodule Minirate.MixProject do
  use Mix.Project

  def project do
    [
      app: :minirate,
      description: "Small rate-limiter.",
      version: "0.1.0",
      elixir: "~> 1.8",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Minirate, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.1.2", only: [:dev, :test], runtime: false}
    ]
  end
end
