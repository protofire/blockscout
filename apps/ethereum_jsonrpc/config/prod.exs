import Config

config :ethereum_jsonrpc, EthereumJSONRPC.Tracer, env: "production", disabled?: false

config :logger, :ethereum_jsonrpc,
  level: :debug,
  path: Path.absname("logs/prod/ethereum_jsonrpc.log"),
  rotate: %{max_bytes: 52_428_800, keep: 19}
