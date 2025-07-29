defmodule BlockScoutWeb.Plug.BlockedIpList do
  @moduledoc """
    Block requests by IP
  """
  alias BlockScoutWeb.AccessHelper

  def init(opts), do: opts

  def call(conn, _opts) do
    if AccessHelper.blocked_access?(conn) do
      AccessHelper.handle_blocked_access(conn, true)
    else
      conn
    end
  end
end
