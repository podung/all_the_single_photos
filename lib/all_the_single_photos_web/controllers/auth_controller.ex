defmodule AllTheSinglePhotosWeb.AuthController do
  use AllTheSinglePhotosWeb, :controller

  plug Ueberauth

  def signin(conn, %{}) do
    # TODO: why is flash not available here?????

    render(conn, "signin.html")
  end


  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user = %{
      token: auth.credentials.token,
      first_name: auth.info.first_name,
      last_name: auth.info.last_name,
      email: auth.info.email,
      provider: "google"
    }

    conn
    |> put_session(:user, user)
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
