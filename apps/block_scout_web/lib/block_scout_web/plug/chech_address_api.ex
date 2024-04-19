defmodule BlockScoutWeb.Plug.CheckAddressAPI do
  import Plug.Conn

  import EthereumJSONRPC.Utility.Bech, only: [decode_bech_32: 1]

  def init(opts), do: opts

  def call(conn, _opts) do
    # if address do
    #   formatted_address = format_address(address)
    #   conn
    #   |> assign(:address_hash_param, formatted_address)
    # else
    #   conn
    # end

    conn
    |> assign_param_if_exists(:address_hash_param)
    |> assign_query_param_if_exists(:q)
  end

  defp assign_param_if_exists(conn, key) do
    value = conn.params[key]

    if value do
      assign(conn, key, format_address(value))
    else
      conn
    end
  end

  defp assign_query_param_if_exists(conn, key) do
    value = conn.query_params[key]

    if value do
      assign(conn, key, format_address(value))
    else
      conn
    end
  end

  defp format_address(address) do
    if String.starts_with?(address, "one") do
      decode_bech_32(address)
    else
      address
    end
  end
end
