defmodule DistilleryConsul.MixProject do
  use Mix.Project

  def project do
    [
      app: :distillery_consul,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:inets]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 2.2 or ~> 3.0", optional: true},
      {:jason,  "~> 1.1",           optional: true}
    ]
  end
end
