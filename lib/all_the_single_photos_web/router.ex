defmodule AllTheSinglePhotosWeb.Router do
  use AllTheSinglePhotosWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug AllTheSinglePhotosWeb.Plugs.SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug :browser

    plug AllTheSinglePhotosWeb.Plugs.RequireAuth
  end

  scope "/", AllTheSinglePhotosWeb do
    pipe_through :authenticated

    get "/", PageController, :index
  end

  scope "/auth", AllTheSinglePhotosWeb do
    pipe_through :browser

    get "/signin", AuthController, :signin
    get "/signout", AuthController, :delete

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end



  # Other scopes may use custom stacks.
  # scope "/api", AllTheSinglePhotosWeb do
  #   pipe_through :api
  # end
end
