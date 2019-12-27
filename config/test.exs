use Mix.Config

# Configure your database
config :all_the_single_photos, AllTheSinglePhotos.Repo,
  username: "postgres",
  password: "postgres",
  database: "all_the_single_photos_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :all_the_single_photos, AllTheSinglePhotosWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
