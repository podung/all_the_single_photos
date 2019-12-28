defmodule AllTheSinglePhotosWeb.AuthController do
  use AllTheSinglePhotosWeb, :controller

  plug Ueberauth

  def sign_in(conn, %{}) do
    # TODO: why is flash not available here?????

    text conn, "onwards to signin"
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
