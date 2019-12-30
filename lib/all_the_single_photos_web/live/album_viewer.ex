defmodule AllTheSinglePhotosWeb.AlbumViewer do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      <h3>your photo albums:</h3>
      <button phx-click="next">next</button>

      <%= if @loading do %>

        <div>Loading<%= assigns[:progress] %></div>

      <% else %>
        <ul>
          <%= Enum.map(assigns[:albums], fn album -> %>
            <li><%= Map.get(album, "title") %></li>
          <% end) %>
        </ul>

      <% end %>

      <button phx-click="photos">photos</button>

      <%= if @photos_loading do %>

        <div>Loading<%= assigns[:photos_progress] %></div>

      <% else %>
        <ul>
          <%= Enum.map(assigns[:photos], fn photo -> %>
            <li><%= Map.get(photo, "id") %></li>
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
      |> assign(:photos, [])
      |> assign(:loading, false)
      |> assign(:photos_loading, false)
      |> assign(:progress, "")
      |> assign(:photos_progress, "")

    {:ok, socket}
  end

  def handle_event("next", _, socket) do
    auth_token = socket.assigns[:token]
    next_page_token = Map.get(socket.assigns, :next_page_token)

    caller_pid = self()
    Task.async(fn -> AllTheSinglePhotos.PhotosApi.fetch_all_albums(auth_token, caller_pid) end)

    { :noreply, assign(socket, :loading, true) }
  end

  def handle_event("photos", _, socket) do
    auth_token = socket.assigns[:token]

    caller_pid = self()
    Task.async(fn -> AllTheSinglePhotos.PhotosApi.fetch_all_photos(auth_token, caller_pid) end)

    { :noreply, assign(socket, :photos_loading, true) }
  end


  def handle_info({ :progress }, socket) do
    { :noreply, update(socket, :progress, &(&1 <> ".")) }
  end

  def handle_info({ :photos_progress }, socket) do
    { :noreply, update(socket, :photos_progress, &(&1 <> ".")) }
  end

  def handle_info({ _task, { :ok, { :photos, result } }}, socket) do
    IO.inspect result

    socket = socket
    |> assign(:photos, Map.get(result, :photos))
    |> assign(:photos_loading, false)

    # ITS DONE
    { :noreply, socket }
  end

  def handle_info({ _task, { :ok, result }}, socket) do
    socket = socket
    |> assign(:albums, Map.get(result, :albums))
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
end
