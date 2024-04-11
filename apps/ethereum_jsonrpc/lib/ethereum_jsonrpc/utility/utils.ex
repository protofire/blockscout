defmodule EthereumJSONRPC.Utility.Bech do
  @moduledoc """
  This module provides utility functions for working with Bech32 encoding in Ethereum JSON-RPC.
  """

  require Bech32

  @doc """
  Decodes a Bech32-encoded value if it exists in the given object.

  If the value associated with the given key in the object is a Bech32-encoded string
  starting with 'one1', it decodes the value and replaces it in the object.

  ## Examples

      iex> object = %{"address" => "one1abcde"}
      iex> EthereumJSONRPC.Utility.Bech.decode_bech_32_if_exist(object, "address")
      %{"address" => "0x6162636465"}

  """
  def decode_bech_32_if_exist(object, key) do
    value = Map.get(object, key)

    if !is_nil(value) && String.starts_with?(value, "one1") do
      Map.put(object, key, decode_bech_32(Map.get(object, key)))
    else
      object
    end
  end

  @doc """
  Decodes a Bech32-encoded value and returns the corresponding Ethereum address.

  ## Examples

      iex> EthereumJSONRPC.Utility.Bech.decode_bech_32("one1abcde")
      "0x6162636465"

  """
  def decode_bech_32(value) do
    case Bech32.decode(value) do
      {:ok, _, binary} ->
        hex_address = Base.encode16(binary, case: :lower)
        "0x" <> hex_address
    end
  end
end
