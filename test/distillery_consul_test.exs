defmodule DistilleryConsulTest do
  use ExUnit.Case
  doctest DistilleryConsul

  alias DistilleryConsul.Client, as: Consul

  @fixtures_path Path.join([__DIR__, "fixtures"])
  @app_path Path.join([@fixtures_path, "app"])
  @app_bin Path.join([@app_path, "_build", "prod", "rel", "app", "bin", "app"])
  @sys_config Path.join([@app_path, "_build", "prod", "rel", "app", "var", "sys.config"])

  @url "https:/example.com:8081/service"
  @level :info
  @rate_limit 100

  setup_all do
    Consul.put!("app/url", @url)
    Consul.put!("app/level", "#{@level}")
    Consul.put!("app/rate_limit", "#{@rate_limit}")
    on_exit fn -> 
      Consul.delete!("app")
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

      do_exec(@app_bin, ["run"])
      :timer.sleep(5)
      do_exec(@app_bin, ["stop"])

      {:ok, [config]} = :file.consult(@sys_config)
      assert @url == config[:app][:url]
      assert @level == config[:app][:level]
      assert @rate_limit == config[:app][:rate_limit]
    after
      File.cd!(old_dir)
    end
  end


  defp mix(command, args \\ []) do
    do_exec("mix", [command | args], env: [{"MIX_ENV", "prod"}])
  end

  defp do_exec(command, args, opts \\ []) do
    opts = Keyword.merge([stderr_to_stdout: true], opts)
    case System.cmd(command, args, opts) do
      {output, 0} when is_binary(output) ->
        {:ok, output}
      {output, non_zero_exit} when is_binary(output) ->
        {:error, non_zero_exit, output}
    end
  end
end
