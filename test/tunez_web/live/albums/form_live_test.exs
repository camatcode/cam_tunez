defmodule TunezWeb.Albums.FormLiveTest do
  use TunezWeb.ConnCase, async: true

  alias Ash.Error.Forbidden
  alias Tunez.Music, warn: false
  alias Tunez.Music.Album
  alias Tunez.Music.Artist

  describe "creating a new album" do
    test "errors for forbidden users", %{conn: conn} do
      artist = generate(artist())

      assert_raise(Forbidden, fn ->
        conn
        |> insert_and_authenticate_user()
        |> visit(~p"/artists/#{artist}/albums/new")
      end)
    end

    test "succeeds when valid details are entered", %{conn: conn} do
      artist = generate(artist())

      conn
      |> insert_and_authenticate_user(:admin)
      |> visit(~p"/artists/#{artist}/albums/new")
      |> fill_in("Name", with: "Final Days")
      |> fill_in("Year Released", with: 2021)
      |> click_button("Save")

      #   |> assert_has(flash(:info), text: "Album saved successfully")

      album = get_by_name!(Album, "Final Days")
      assert album.artist_id == artist.id
    end

    @tag skip: "Can be enabled during chapter 8.
      Also need to change `_conn` to `conn` below"
    test "track data can be added and removed for an album", %{conn: _conn} do
      # artist = generate(artist())

      # conn
      # |> insert_and_authenticate_user(:admin)
      # |> visit(~p"/artists/#{artist}/albums/new")
      # |> fill_in("Name", with: "Sample With Tracks")
      # |> fill_in("Year Released", with: 2021)
      # |> click_link("Add Track")
      # |> click_link("Add Track")
      # |> click_link("Add Track")
      # |> fill_in("tr[data-id=0] input", "Name", with: "First Track")
      # |> fill_in("tr[data-id=0] input", "Duration", with: "2:22")
      # |> fill_in("tr[data-id=1] input", "Name", with: "Second Track")
      # |> fill_in("tr[data-id=1] input", "Duration", with: "3:33")
      # |> fill_in("tr[data-id=2] input", "Name", with: "Third Track")
      # |> fill_in("tr[data-id=2] input", "Duration", with: "4:44")
      # |> click_link("tr[data-id=1] a", "Delete")
      # |> click_button("Save")
      # |> assert_has(flash(:info), text: "Album saved successfully")

      # album = get_by_name!(Tunez.Music.Album, "Sample With Tracks", load: [:tracks])
      # assert ["First Track", "Third Track"] == Enum.map(album.tracks, & &1.name)
    end

    test "fails when invalid details are entered", %{conn: conn} do
      artist = generate(artist())

      conn
      |> insert_and_authenticate_user(:admin)
      |> visit(~p"/artists/#{artist}/albums/new")
      |> fill_in("Name", with: "Missing Year")
      |> click_button("Save")

      # |> assert_has(flash(:error), text: "Could not save album data")

      refute get_by_name(Artist, "Missing Year")
    end
  end

  describe "updating an existing album" do
    test "errors for forbidden users", %{conn: conn} do
      album = generate(album())

      assert_raise(Forbidden, fn ->
        conn
        |> insert_and_authenticate_user()
        |> visit(~p"/albums/#{album}/edit")
      end)
    end

    test "succeeds when valid details are entered", %{conn: conn} do
      album = generate(album(name: "Old Name"))

      conn
      |> insert_and_authenticate_user(:admin)
      |> visit(~p"/albums/#{album}/edit")
      |> fill_in("Name", with: "New Name")
      |> click_button("Save")

      #  |> assert_has(flash(:info), text: "Album saved successfully")
      # TODO something is wrong here
      album = Music.get_album_by_id!(album.id)
      #  assert album.name == "New Name"
    end

    @tag skip: "Also need to change `_conn` to `conn` below"
    test "fails when invalid details are entered", %{conn: _conn} do
      # TODO FIXME something is wrong here
      # album = generate(album(name: "Old Name"))

      # conn
      # |> insert_and_authenticate_user(:admin)
      # |> visit(~p"/albums/#{album}/edit")
      # |> fill_in("Name", with: "")
      # |> click_button("Save")
      # |> assert_has(flash(:error), text: "Could not save album data")

      # album = Music.get_album_by_id!(album.id)
      # assert album.name == "Old Name"
    end
  end
end
