defmodule TunezWeb.Artists.IndexLiveTest do
  use TunezWeb.ConnCase, async: true

  alias Tunez.Music
  alias TunezWeb.Artists.IndexLive

  describe "cam tests >" do
    setup do
      name = "Valkyrie's Fury"
      bio = "A power metal band hailing from Tallinn, Estonia"

      artists =
        Tunez.Seeder.artists()
        |> Enum.map(&Music.create_artist!/1)
        |> Enum.sort_by(& &1.name)

      albums =
        Tunez.Seeder.albums()
        |> Enum.map(fn album ->
          artist = Enum.random(artists)

          album =
            Map.put(album, :artist_id, artist.id)
            |> Map.delete(:artist_name)
            |> Map.delete(:tracks)

          Music.create_album!(album)
        end)

      refute Enum.empty?(artists)

      %{name: name, bio: bio, artists: artists, albums: albums}
    end

    test "Pagination", _state do
      page = Music.search_artists!("a")

      [sort_by: "name", q: "a"] =
        IndexLive.query_string(page, "a", "name", "prev")

      [sort_by: "-inserted_at", q: "a", limit: 12, offset: 12] =
        IndexLive.query_string(page, "a", "-inserted_at", "next")
    end
  end

  describe "render/1" do
    @tag skip: "Also need to change `_conn` to `conn` below"
    test "can view a list of artists", %{conn: _conn} do
      # [artist1, artist2] = generate_many(artist(), 2)

      # conn
      # |> visit(~p"/")
      # |> assert_has("#artist-#{artist1.id}")
      # |> assert_has("#artist-#{artist2.id}")
    end

    @tag skip: "Also need to change `_conn` to `conn` below"
    test "has a link to add a new artist for valid users", %{conn: _conn} do
      # conn
      # |> visit(~p"/")
      # |> refute_has(link(~p"/artists/new"))

      # conn
      # |> insert_and_authenticate_user(:admin)
      # |> visit(~p"/")
      # |> assert_has(link(~p"/artists/new"))
    end
  end

  describe "artist_card/1" do
    @tag skip: "Also need to change `_conn` to `conn` below"
    test "shows the artist name and their album count", %{conn: _conn} do
      # artist = generate(artist())

      # conn
      # |> visit(~p"/")
      # |> assert_has(link(~p"/artists/#{artist.id}"))
      # |> refute_has("span", text: "0 albums")

      # # Add an album for the artist
      # generate(album(artist_id: artist.id))

      # # Now it should say that they have an album
      # conn
      # |> visit(~p"/")
      # |> assert_has(link(~p"/artists/#{artist.id}"))
      # |> assert_has("span", text: "1 album")
    end
  end

  describe "events" do
    @tag skip: "Also need to change `_conn` to `conn` below"
    test "results can be paged through", %{conn: _conn} do
      # generate_many(artist(), 3)

      # # One record per page
      # conn
      # |> visit(~p"/?limit=1")
      # |> assert_has("[data-role=artist-card]", count: 1)
      # |> click_link("Next")
      # |> assert_has("[data-role=artist-card]", count: 1)
      # |> click_link("Next")
      # |> assert_has("[data-role=artist-card]", count: 1)
      # |> assert_has("a[disabled]", text: "Next")

      # # By default all records will fit on one page
      # conn
      # |> visit(~p"/")
      # |> assert_has("[data-role=artist-card]", count: 3)
    end

    @tag skip: "Also need to change `_conn` to `conn` below"
    test "results can be reordered", %{conn: _conn} do
      # artist1 = generate(artist(name: "gamma"))
      # generate(album(artist_id: artist1.id, year_released: 2025))

      # artist2 = generate(artist(name: "beta"))
      # generate_many(album(artist_id: artist2.id, year_released: 2023), 3)

      # _artist3 = generate(artist(name: "omega"))

      # artist4 = generate(artist(name: "alpha"))
      # generate_many(album(artist_id: artist4.id, year_released: 2024), 2)

      # conn
      # |> visit(~p"/")
      # |> assert_ordered_artists(["alpha", "omega", "beta", "gamma"])
      # |> select("sort by:", option: "number of albums")
      # |> assert_ordered_artists(["beta", "alpha", "gamma", "omega"])
      # |> select("sort by:", option: "name")
      # |> assert_ordered_artists(["alpha", "beta", "gamma", "omega"])
      # |> select("sort by:", option: "latest album release")
      # |> assert_ordered_artists(["gamma", "alpha", "beta", "omega"])
    end

    @tag skip: "Also need to change `_conn` to `conn` below"
    test "results can be searched", %{conn: _conn} do
      # generate(artist(name: "gamma"))
      # generate(artist(name: "beta"))
      # generate(artist(name: "omega"))
      # generate(artist(name: "alpha"))

      # conn
      # |> visit(~p"/")
      # |> fill_in("Search", with: "e")
      # |> submit()
      # |> assert_ordered_artists(["omega", "beta"])
    end

    def assert_ordered_artists(session, list) do
      Enum.map(Enum.with_index(list, 1), fn {name, index} ->
        assert_has(session, "[data-role='artist-name']", text: name, at: index)
      end)

      session
    end
  end
end
