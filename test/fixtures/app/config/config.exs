use Mix.Config

config :app, 
  rate_limit: {:consul, :integer, "app/rate_limit"},
  url: {:consul, "app/url"},
  level: {:consul, :atom, "app/level"}
