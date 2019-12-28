# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :all_the_single_photos,
  ecto_repos: [AllTheSinglePhotos.Repo]

# Configures the endpoint
config :all_the_single_photos, AllTheSinglePhotosWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "niujDfjLQmE5C+LJXCCSzQMXf2RQN6cybA1mN2NvgIsofByO/C92K5kX7ubFiU8Q",
  render_errors: [view: AllTheSinglePhotosWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AllTheSinglePhotos.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
         signing_salt: "EOfkr4rqZk3pAf4zkLc69RpHCsJeDaUs"
       ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :ueberauth, Ueberauth,
  providers: [
        google: {Ueberauth.Strategy.Google, [prompt: "select_account", default_scope: "email profile"]}
      ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: {System, :get_env, ["GOOGLE_CLIENT_ID"]},
    client_secret: {System, :get_env, ["GOOGLE_CLIENT_SECRET"]}
