defmodule TunezWeb.Artists.FormLive do
  use TunezWeb, :live_view

  def mount(%{"id" => artist_id}, _session, socket) do
    form =
      artist_id
      |> Tunez.Music.get_artist_by_id!(actor: socket.assigns.current_user)
      |> Tunez.Music.form_to_update_artist(actor: socket.assigns.current_user)
      |> AshPhoenix.Form.ensure_can_submit!()

    socket
    |> assign(form: form)
    |> assign(:page_title, "Update Artist")
    |> then(&{:ok, &1})
  end

  def mount(_params, _session, socket) do
    form =
      Tunez.Music.form_to_create_artist(actor: socket.assigns.current_user)
      |> AshPhoenix.Form.ensure_can_submit!()

    socket
    |> assign(:form, to_form(form))
    |> assign(:page_title, "New Artist")
    |> then(&{:ok, &1})
  end

  def handle_event("validate", %{"form" => form_data}, socket) do
    socket
    |> update(:form, &AshPhoenix.Form.validate(&1, form_data))
    |> then(&{:noreply, &1})
  end

  def handle_event("save", %{"form" => form_data}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: form_data) do
      {:ok, artist} ->
        socket
        |> put_flash(:info, "Artist saved successfully")
        |> push_navigate(to: ~p"/artists/#{artist}")

      {:error, form} ->
        socket
        |> put_flash(:error, "Failed to save artist")
        |> assign(:form, form)
    end
    |> then(&{:noreply, &1})
  end

  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <.header>
        <.h1>{@page_title}</.h1>
      </.header>

      <.simple_form
        :let={form}
        id="artist_form"
        as={:form}
        for={@form}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={form[:name]} label="Name" />
        <.input field={form[:biography]} type="textarea" label="Biography" />
        <:actions>
          <.button type="primary">Save</.button>
        </:actions>
      </.simple_form>
    </Layouts.app>
    """
  end
end
