defmodule AllTheSinglePhotosWeb.AuthController do
  use AllTheSinglePhotosWeb, :controller
  plug Ueberauth

  def sign_in(conn, %{}) do
    # TODO: why is flash not available here?????

    text conn, "onwards to signin"
  end
end
