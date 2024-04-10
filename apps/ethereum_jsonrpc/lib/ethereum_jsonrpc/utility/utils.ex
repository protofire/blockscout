defmodule EthereumJSONRPC.Utility.Bech do
  require Bech32

  def decode_bech_32_if_exist(object, key) do
    value = Map.get(object, key)
    if !is_nil(value) &&  String.starts_with?(value, "one1") do
      Map.put(object, key, decode_bech_32(Map.get(object, key)))
    else
      object
    end
  end

  def decode_bech_32(value) do
    case Bech32.decode(value) do
      {:ok, _, binary} ->
        hex_address = Base.encode16(binary, case: :lower)
        "0x" <> hex_address
    end
  end
end
