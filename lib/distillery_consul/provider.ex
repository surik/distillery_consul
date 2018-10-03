defmodule DistilleryConsul.Provider do
  alias Mix.Releases.Config.Provider

  def init(_) do
    # Start Mix if not started to allow calling Mix APIs
    started? = List.keymember?(Application.started_applications(), :mix, 0)

    {:ok, deps} = Application.ensure_all_started(:distillery_consul)

     unless started? do
      :ok = Application.start(:mix)
      # Always set MIX_ENV to :prod, unless otherwise given
      env = System.get_env("MIX_ENV") || "prod"
      System.put_env("MIX_ENV", env)
      Mix.env(String.to_atom(env))
    end

    try do
      path = "${SRC_SYS_CONFIG_PATH}"
      with {:ok, path} <- Provider.expand_path(path) do
        path
        |> eval!()
        |> merge_config()
        |> Mix.Config.persist()
      else
        {:error, reason} ->
          exit(reason)
      end
    else
      _ ->
        :ok
    after
      unless started? do
        # Do not leave Mix started if it was started here
        # The boot script needs to be able to start it
        :ok = Application.stop(:mix)
      end
      for dep <- deps, do: Application.stop(dep)
    end
  end

  defp eval!(path) do
    {:ok, [config]} = :file.consult(path)
    config
  end

  defp merge_config(runtime_config) do
    Enum.flat_map(runtime_config, fn {app, app_config} ->
      app_config = fetch_from_consul(app_config)
      all_env = Application.get_all_env(app)
      Mix.Config.merge([{app, all_env}], [{app, app_config}])
    end)
  end

  defp fetch_from_consul(app_config, acc \\ [])

  defp fetch_from_consul([], acc), do: acc
  defp fetch_from_consul([{key, {:consul, value}} | tail], acc) do
    value = hd(Consul.Kv.fetch!(value).body)["Value"]
    fetch_from_consul(tail, [{key, value} | acc])
  end
  defp fetch_from_consul([head | tail], acc), do:
    fetch_from_consul(tail, [head | acc])

end
