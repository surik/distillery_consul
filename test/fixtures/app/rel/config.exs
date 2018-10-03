~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"sNXG5@U6cD>4*w)tIB$hJFWZPoPj_CF3rw~QswhIZO@:3?&RoM:VSDX9BBJGP;{N"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"&lJxNXk6x05YRJ2u%9yloTJZ@/mvr]A9x$Z8rHS<J!Uq}3B4`fE8SoRtxp`W8@d^"
end

release :app do
  set version: current_version(:app)
  set applications: [
    :runtime_tools
  ]
  set config_providers: [
    {DistilleryConsul.Provider, [host: "http://localhost", port: 8500, token: nil]}
  ]
end
