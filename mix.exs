defmodule DistilleryConsul.MixProject do
  use Mix.Project

  def project do
    [
      app: :distillery_consul,
      version: "0.2.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
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

  defp description do
    "Distillery config provider for Consul KV"
  end

  defp package do
    [maintainers: ["Yury Gargay"],
     licenses: ["MIT"],
     links: %{"Github" => "https://github.com/surik/distillery_consul"}]
  end
end
