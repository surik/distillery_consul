defmodule DistilleryConsul.Client do
  @moduledoc """
  Simple implementation of get, put and delete Consul KV methiods.
  It uses httpc in order to avoid adding additional dependencies to release.
  """

  alias :httpc, as: HTTPClient

  @default_opts [host: "http://localhost", port: 8500, token: nil]

  def get!(key, opts \\ @default_opts) do
    url = build_url(key, opts)
    headers = build_headers(opts)
    with {:ok, {_, _, body}} <- HTTPClient.request(:get, {url, headers}, [], []) do
      body
      |> Jason.decode! # TODO: make json decode configurable
      |> List.first()
      |> Map.get("Value")
      |> Base.decode64!
    end
  end

  def put!(key, value, opts \\ @default_opts) do
    url = build_url(key, opts)
    headers = build_headers(opts)
    {:ok, _} = HTTPClient.request(:put, {url, headers, [], value}, [], [])
    :ok
  end

  def delete!(key, opts \\ @default_opts) do
    url = build_url(key, opts)
    headers = build_headers(opts)
    {:ok, _} = HTTPClient.request(:delete, {url, headers}, [], [])
    :ok
  end

  defp build_headers(opts) do
    opts = Keyword.merge(@default_opts, opts)
    if token = opts[:token] do
      [{'X-Consul-Token', to_charlist(token)}]
    else
      []
    end
  end

  defp build_url(key, opts) do
    opts = Keyword.merge(@default_opts, opts)
    "#{opts[:host]}:#{opts[:port]}/v1/kv/#{key}" |> to_charlist
  end
end
