defmodule Indexer.Transform.Utils do
  require Bech32

  def decode_bench_32_if_exist(object, key) do
    if Map.has_key?(object, key) && String.starts_with?(Map.get(object, key), "one1") do
      Map.put(object, key, decode_bench_32(Map.get(object, key)))
    else
      object
    end
  end

  defp decode_bench_32(value) do
    case Bech32.decode(value) do
      {:ok, _, binary} ->
        hex_address = Base.encode16(binary, case: :lower)
        "0x" <> hex_address
    end
  end
end
