defmodule AllTheSinglePhotosWeb.Plugs.SetUser do
  import Plug.Conn
  import Phoenix.Controller

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns[:user] do
      conn
    else
      user = get_session(conn, :user)

      #TODO: get this from DB later?  Just set a user_id and fetch?

      assign(conn, :user, user)
    end
  end
end
