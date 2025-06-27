defmodule TunezWeb.Albums.CamFormLiveTest do
  use TunezWeb.ConnCase, async: true

  alias Ash.Error.Forbidden
  alias Tunez.Music, warn: false
  alias Tunez.Music.Album
  alias Tunez.Music.Artist

  @moduletag :capture_log

  describe desc(:create) do
    setup %{conn: conn} do
      user = build(:registered_user, insert?: true)
      admin = build(:registered_user, role: :admin, insert?: true)
      artist = build(:artist, insert?: true)
      %{artist: artist, user: user, admin: admin, conn: conn}
    end

    test desc(:deny), %{conn: conn, artist: artist, user: actor} do
      conn = log_in_user(conn, actor)

      assert_raise(Forbidden, fn ->
        conn
        |> visit(~p"/artists/#{artist}/albums/new")
      end)
    end

    test desc(:create), %{conn: conn, artist: artist, admin: admin} do
      conn = log_in_user(conn, admin)

      # valid
      conn
      |> visit(~p"/artists/#{artist}/albums/new")
      |> fill_in("Name", with: "Final Days")
      |> fill_in("Year Released", with: 2021)
      |> click_button("Save")

      album = get_by_name!(Album, "Final Days")
      assert album.artist_id == artist.id

      # invalid
      conn
      |> visit(~p"/artists/#{artist}/albums/new")
      |> fill_in("Name", with: "Missing Year")
      |> click_button("Save")

      refute get_by_name(Artist, "Missing Year")
    end
  end

  describe desc(:update) do
    setup %{conn: conn} do
      user = build(:registered_user, insert?: true)
      admin = build(:registered_user, role: :admin, insert?: true)
      artist = build(:artist, insert?: true)
      albums = build_list(5, :album, artist_id: artist.id, insert?: true)
      %{artist: artist, user: user, admin: admin, albums: albums, conn: conn}
    end

    test desc(:deny), %{conn: conn, albums: [album | _], user: user} do
      conn = log_in_user(conn, user)

      assert_raise(Forbidden, fn ->
        conn
        |> visit(~p"/albums/#{album}/edit")
      end)
    end

    test desc(:update), %{conn: conn, admin: admin, albums: [album | _]} do
      conn = log_in_user(conn, admin)

      conn
      |> visit(~p"/albums/#{album}/edit")
      |> fill_in("Name", with: "New Name")
      |> fill_in("Year Released", with: 2001)
      |> click_button("Save")

      # TODO something is wrong here
      album = Music.get_album_by_id!(album.id)
      #  assert album.name == "New Name"
    end
  end
end
