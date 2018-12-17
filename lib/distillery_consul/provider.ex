defmodule DistilleryConsul.Provider do
  alias Mix.Releases.Config.Provider

  def init(opts) do
    {:ok, deps} = Application.ensure_all_started(:distillery_consul)

    started? = List.keymember?(Application.started_applications(), :mix, 0)
    deps = unless started? do
      :ok = Application.start(:mix)
      # Always set MIX_ENV to :prod, unless otherwise given
      env = System.get_env("MIX_ENV") || "prod"
      System.put_env("MIX_ENV", env)
      Mix.env(String.to_atom(env))
      [:mix | deps]
    else
      deps
    end

    try do
      path = "${SRC_SYS_CONFIG_PATH}"
      with {:ok, path} <- Provider.expand_path(path) do
        path
        |> eval!()
        |> merge_config(opts)
        |> Mix.Config.persist()
      else
        {:error, reason} ->
          exit(reason)
      end
    else
      _ ->
        :ok
    after
      for dep <- deps, do: Application.stop(dep)
    end
  end

  defp eval!(path) do
    {:ok, [config]} = :file.consult(path)
    config
  end

  defp merge_config(runtime_config, opts) do
    Enum.flat_map(runtime_config, fn {app, app_config} ->
      app_config = fetch_from_consul(app_config, opts)
      all_env = Application.get_all_env(app)
      Mix.Config.merge([{app, all_env}], [{app, app_config}])
    end)
  end

  defguard is_type(type) when type in [:integer, :float, :string, :atom]

  defp fetch_from_consul(app_config, opts, acc \\ [])

  defp fetch_from_consul([], _opts, acc), do: acc
  defp fetch_from_consul([{key, {:consul, type, value}} | tail], opts, acc) 
   when is_type(type) do
    value = DistilleryConsul.Client.get!(value, opts)
            |> convert_type(type)
    fetch_from_consul(tail, opts, [{key, value} | acc])
  end
  defp fetch_from_consul([{key, {:consul, value}} | tail], opts, acc) do
    value = DistilleryConsul.Client.get!(value, opts)
    fetch_from_consul(tail, opts, [{key, value} | acc])
  end
  defp fetch_from_consul([head | tail], opts, acc), do:
    fetch_from_consul(tail, opts, [head | acc])


  defp convert_type(value, :string), do: value
  defp convert_type(value, :integer), do: String.to_integer(value)
  defp convert_type(value, :float), do: String.to_float(value)
  defp convert_type(value, :atom), do: String.to_atom(value)
end
