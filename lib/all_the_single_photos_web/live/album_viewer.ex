defmodule AllTheSinglePhotosWeb.AlbumViewer do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      <h1>Your photo albums:</h1>
      <ul>
        <%= Enum.map(assigns[:albums], fn album -> %>
          <li><%= Map.get(album, "title") %></li>
        <% end) %>
      </ul>

      <button phx-click="next">next</button>
    </div>
    """
  end

  def mount(session, socket) do

    socket = socket
      |> assign(:token, session.token)
      |> assign(:albums, [])

    {:ok, socket}
  end

  def handle_event("next", _, socket) do
    pageToken = Map.get(socket.assigns, :nextPageToken)
    url = "https://photoslibrary.googleapis.com/v1/albums?pageToken=#{pageToken}"


    IO.puts url
    headers = ["Authorization": "Bearer #{socket.assigns[:token]}", "Accept": "Application/json; Charset=utf-8"]


    with {:ok, %HTTPoison.Response{status_code: 200, body: body }} <- HTTPoison.get(url, headers),
         {:ok, decoded} <- Poison.decode(body)
    do

      IO.inspect(decoded)
      #TODO: make a decoder, that just decodes the data I need

      socket = socket
        |> assign(:albums, Map.get(decoded, "albums"))
        |> assign(:nextPageToken, Map.get(decoded, "nextPageToken"))

        {:noreply, socket}
    else
      #TODO: report error somewhere
      err ->
        IO.puts "I blew up: #{err}"
        {:noreply, socket}
    end
  end

  #TODO: move a bunch of this stuff to AllTheSinglePhotos - out of this file and out of web
end
