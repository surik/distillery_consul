use Mix.Config

config :app, 
  rate_limit: 100,
  url: {:consul, "app/url"},
  level: {:consul, "app/level"}
