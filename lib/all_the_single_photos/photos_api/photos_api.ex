defmodule AllTheSinglePhotos.PhotosApi do
  @google_base_url "https://photoslibrary.googleapis.com/"
  @albums_path "/v1/albums"
  @photos_path "/v1/mediaItems:search"

  def fetch_all_albums(auth_token, caller) do
    fetch_albums_recursive(auth_token, "", caller)
  end

  def fetch_all_photos(auth_token, caller) do
    fetch_photos_recursive(auth_token, "", caller)
  end

  defp fetch_photos_recursive(auth_token, next_page_token, caller, acc \\ []) do
    send(caller, { :photos_progress })

    with { :ok, result } <- fetch_photos(auth_token, next_page_token) do
      case result do
        %{ photos: photos, next_page_token: nil } -> { :ok, { :photos, %{ photos: acc ++ photos } } }
        %{ photos: photos, next_page_token: page_token } -> fetch_photos_recursive(auth_token, page_token, caller, acc ++ photos)
      end
    else
      err -> { :error, err }
    end
  end

  defp fetch_albums_recursive(auth_token, next_page_token, caller, acc \\ []) do
    send(caller, { :progress })

    with { :ok, result } <- fetch_albums(auth_token, next_page_token) do
      case result do
        %{ albums: albums, next_page_token: nil } -> { :ok, %{ albums: acc ++ albums } }
        %{ albums: albums, next_page_token: page_token } -> fetch_albums_recursive(auth_token, page_token, caller, acc ++ albums)
      end
    else
      err -> { :error, err }
    end
  end

  def fetch_albums(auth_token, next_page_token) do
    url = albums_url(next_page_token)
    headers = headers(auth_token)

    with {:ok, %HTTPoison.Response{status_code: 200, body: body }} <- HTTPoison.get(url, headers),
         {:ok, decoded} <- Poison.decode(body)
    do
      #TODO: make a decoder, that just decodes the data I need

      {:ok, %{
          albums: Map.get(decoded, "albums"),
          next_page_token: Map.get(decoded, "nextPageToken")
        }
      }
    else
      #TODO: report error somewhere
      err -> { :error, err }
    end
  end

  def fetch_photos(auth_token, next_page_token) do
    url = photos_url
    headers = headers(auth_token)
    { :ok, request_body } = next_page_token
      |> photos_search_params
      |> Poison.encode


    foo = HTTPoison.post(url, request_body, headers)

    with {:ok, %HTTPoison.Response{status_code: 200, body: body }} <- foo,
         {:ok, decoded} <- Poison.decode(body)
    do
      #TODO: make a decoder, that just decodes the data I need

      {:ok, %{
          photos: Map.get(decoded, "mediaItems"),
          next_page_token: Map.get(decoded, "nextPageToken")
        }
      }
    else
      #TODO: report error somewhere
      err -> { :error, err }
    end
  end

  defp albums_url(next_page_token) do
    @google_base_url <> @albums_path <> "?pageToken=#{next_page_token}&pageSize=50"
  end

  defp photos_url do
    @google_base_url <> @photos_path
  end

  defp photos_search_params(pageToken) do
    %{
      "pageToken": pageToken,
      "pageSize": 100,
      "filters": %{
        "dateFilter": %{
          "ranges": [
            %{
              "startDate": %{
                "year": 2019,
                "month": 12,
                "day": 25,
              },
              "endDate": %{
                "year": 2019,
                "month": 12,
                "day": 25,
              }
            }
          ]
        }
      }
    }
  end

  defp headers(auth_token) do
    ["Authorization": "Bearer #{auth_token}", "Accept": "Application/json; Charset=utf-8"]
  end
end
