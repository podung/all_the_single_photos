defmodule AllTheSinglePhotosWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias AllTheSinglePhotosWeb.Router.Helpers

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns[:user] do
      conn
    else
      conn
      |> put_flash(:error, "Please sign in to find all your single photos")
      |> redirect(to: Helpers.auth_path(conn, :signin))
      |> halt()
    end
  end
end
