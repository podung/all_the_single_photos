defmodule AllTheSinglePhotos.Repo do
  use Ecto.Repo,
    otp_app: :all_the_single_photos,
    adapter: Ecto.Adapters.Postgres
end
