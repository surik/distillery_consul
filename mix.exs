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
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:consul, "~> 1.1"}
    ]
  end
end
