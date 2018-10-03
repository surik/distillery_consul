# DistilleryConsul

[![Build Status](https://travis-ci.org/surik/distillery_consul.svg?branch=master)](https://travis-ci.org/surik/distillery_consul)

Distillery config provider for Consul KV.

Links:
* [Custom Configuration Providers](https://hexdocs.pm/distillery/extensibility/config_providers.html)
* [Consul Key/Value Store](https://www.consul.io/intro/getting-started/kv.html)

## Installation and Using

The package can be installed by adding `distillery_consul` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:distillery_consul, "~> 0.1.0"},
    {:jason, "~> 1.1"}
  ]
end
```

Then add provider to your release configuration in `rel/config.exs`:

```elixir
release :app do
  set version: current_version(:app)
  set applications: [
    :runtime_tools
  ]
  set config_providers: [
    {DistilleryConsul.Provider, [
      host: "http://localhost", 
      port: 8500, 
      token: "ConsulAccessToken12345" # may be absent
    ]}
  ]
```

Now you can use `{:consul, "some/key"}` as value in your Elixir configuration file.

The following configuration:

```elixir
config :app, 
  rate_limit: 100,
  url: {:consul, "app/url"},
  level: {:consul, "app/level"}
```

They will be changed based on values in Consul KV during release startup:

```
$ _build/dev/rel/app/bin/app console
...
iex(app@127.0.0.1)1> Application.get_all_env(:app)
[rate_limit: 100, url: "https:/example.com:8081/service", level: "info"]
```
