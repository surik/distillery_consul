defmodule DistilleryConsulTest do
  use ExUnit.Case
  doctest DistilleryConsul

  @fixtures_path Path.join([__DIR__, "fixtures"])
  @app_path Path.join([@fixtures_path, "app"])
  @sys_config Path.join([@app_path, "_build", "prod", "rel", "app", "var", "sys.config"])

  @url "https:/example.com:8081/service"
  @level "info"

  setup_all do
    Consul.Kv.put!("app/url", @url)
    Consul.Kv.put!("app/level", @level)
    on_exit fn -> 
      Consul.Kv.delete("app")
    end
  end

  test "greets the world" do
    assert DistilleryConsul.hello() == :world
  end

  test "build" do
    old_dir = File.cwd!()
    File.cd!(@app_path)
    try do
      assert {:ok, _} = mix("deps.get")
      assert {:ok, _} = mix("release")

      {:ok, [config]} = :file.consult(@sys_config)
      assert @url == config[:app][:url]
      assert @level == config[:app][:level]
    after
      File.cd!(old_dir)
    end
  end


  def mix(command, args \\ []) do
    do_exec("mix", [command | args], env: [{"MIX_ENV", "prod"}])
  end

  defp do_exec(command, args, opts) do
    opts = Keyword.merge([stderr_to_stdout: true], opts)
    case System.cmd(command, args, opts) do
      {output, 0} when is_binary(output) ->
        {:ok, output}
      {output, non_zero_exit} when is_binary(output) ->
        {:error, non_zero_exit, output}
    end
  end
end