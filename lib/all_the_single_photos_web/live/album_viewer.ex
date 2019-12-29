defmodule AllTheSinglePhotosWeb.AlbumViewer do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      <h3>Your photo albums:</h3>
      <button phx-click="next">next</button>

      <%= if @loading do %>

        <div>Loading....</div>

      <%= else %>
        <ul>
          <%= Enum.map(assigns[:albums], fn album -> %>
            <li><%= Map.get(album, "title") %></li>
          <% end) %>
        </ul>

      <% end %>
    </div>
    """
  end

  def mount(session, socket) do
    socket = socket
      |> assign(:token, session.token)
      |> assign(:albums, [])
      |> assign(:loading, false)

    {:ok, socket}
  end

  def handle_event("next", _, socket) do
    auth_token = socket.assigns[:token]
    next_page_token = Map.get(socket.assigns, :next_page_token)

    Task.async(fn -> fetchAlbums(auth_token, next_page_token) end)

    { :noreply, assign(socket, :loading, true) }
  end


  def handle_info({ _task, { :ok, result }}, socket) do
    socket = socket
    |> assign(:albums, Map.get(result, :albums))
    |> assign(:next_page_token, Map.get(result, :next_page_token))
    |> assign(:loading, false)


    # ITS DONE
    { :noreply, socket }
  end

  def handle_info({ _task, { :error, reason }}, socket) do
    IO.puts "I FAILED....."
    IO.inspect reason

    # IT FAILED
    { :noreply, assign(socket, :loading, false) }
  end

  #TODO: Do I have to explicitely handle :DOWN, etc?
  def handle_info(msg, socket) do
    IO.puts "LiveView Process received a message"
    IO.inspect msg

    { :noreply, socket }
  end

  #TODO: move a bunch of this stuff to AllTheSinglePhotos - out of this file and out of web

  def fetchAlbums(auth_token, next_page_token) do
    url = "https://photoslibrary.googleapis.com/v1/albums?pageToken=#{next_page_token}"

    headers = ["Authorization": "Bearer #{auth_token}", "Accept": "Application/json; Charset=utf-8"]

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
end
