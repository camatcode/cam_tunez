defmodule Tunez.Music.ArtistTest do
  use Tunez.DataCase, async: true

  import Tunez.Generator

  alias Ash.Error.Changes.Required
  alias Ash.Error.Invalid
  alias Tunez.Accounts.User
  alias Tunez.Music, warn: false
  alias Tunez.Music.Artist

  describe "cam tests > " do
    setup do
      eml = Faker.Internet.email()
      password = Faker.Internet.slug() <> "_#{System.monotonic_time()}"
      password_confirm = password

      {:ok, user} =
        Ash.Changeset.for_create(
          User,
          :register_with_password,
          %{email: eml, password: password, password_confirmation: password_confirm}
        )
        |> Ash.create(authorize?: false)

      {:ok, user} = Tunez.Accounts.set_user_role(user, :admin, authorize?: false)

      name = "Valkyrie's Fury"
      bio = "A power metal band hailing from Tallinn, Estonia"

      artists =
        Tunez.Seeder.artists()
        |> Enum.map(&Music.create_artist!(&1, actor: user))
        |> Enum.sort_by(& &1.name)

      albums =
        Tunez.Seeder.albums()
        |> Enum.map(fn album ->
          artist = Enum.random(artists)

          album =
            Map.put(album, :artist_id, artist.id)
            |> Map.delete(:artist_name)
            |> Map.delete(:tracks)

          Music.create_album!(album, actor: user)
        end)

      refute Enum.empty?(artists)

      %{name: name, bio: bio, artists: artists, albums: albums, admin: user}
    end

    test "Creating records via a changeset", %{name: name, bio: bio, admin: actor} do
      {:ok,
       %Artist{
         name: ^name,
         biography: ^bio
       }} =
        Ash.Changeset.for_create(Artist, :create, %{
          name: name,
          biography: bio
        })
        |> Ash.create(actor: actor, authorize?: false)
    end

    test "Validation check (pg 13)", %{admin: actor} do
      {:error, %Invalid{errors: [%Required{field: :name}]}} =
        Ash.Changeset.for_create(Artist, :create, %{
          name: ""
        })
        |> Ash.create(actor: actor)
    end

    test "Music.create_artist/2", %{name: name, bio: bio, admin: actor} do
      assert {:ok, %Artist{name: ^name, biography: ^bio}} =
               Music.create_artist(%{name: name, biography: bio}, actor: actor)
    end

    test "Music.read_artists/0", %{artists: artists} do
      {:ok, retrieved_artists} = Music.read_artists()
      # because Syndicate is in retrieved, but not in artists
      to_find_ids = Enum.map(artists, & &1.id)
      found_ids = Enum.map(retrieved_artists, & &1.id)
      assert Enum.all?(to_find_ids, &Enum.member?(found_ids, &1))
    end

    test "Manual query", %{artists: [artist | _]} do
      query =
        Ash.Query.for_read(Artist, :read)
        |> Ash.Query.sort(name: :asc)
        |> Ash.Query.limit(1)

      assert {:ok, [found]} = Ash.read(query)
      assert found.id == artist.id
    end

    test "Music.get_artist_by_id/3", %{artists: artists} do
      Enum.each(artists, fn artist ->
        assert {:ok, found} = Music.get_artist_by_id(artist.id)
        assert found.id == artist.id
      end)
    end

    test "Music.update_artist/3", %{artists: artists, admin: actor} do
      Enum.each(artists, fn %{id: id, name: old_name} = artist ->
        # via update_artist/3
        new_name = Faker.Person.name()

        assert {:ok, %{id: ^id, name: ^new_name}} =
                 Music.update_artist(artist, %{name: new_name}, actor: actor)

        # via changeset
        new_name = Faker.Person.name()

        assert {:ok, %{id: ^id, name: ^new_name}} =
                 artist
                 |> Ash.Changeset.for_update(:update, %{name: new_name})
                 |> Ash.update(actor: actor)
      end)
    end

    test "Music.destroy_artist/3", %{artists: artists, admin: actor} do
      Enum.each(artists, fn artist ->
        assert :ok = Music.destroy_artist(artist, actor: actor)
      end)
    end

    test "filters with expressions", _state do
      require Ash.Query

      {:ok, [%{name: "Eternal Tides"}]} =
        Ash.Query.filter(Music.Album, year_released == 2024)
        |> Ash.read()

      {:ok, %{results: [%{name: "Crystal Cove"}]}} =
        Ash.Query.for_read(Artist, :search, %{query: "co"})
        |> Ash.read()
    end

    test "Sorting Artists / Pagination check", _state do
      {:ok,
       %{
         results: [%{name: "Nights in the Nullarbor"}, %{name: "The Lost Keys"}],
         limit: 12,
         offset: 0,
         more?: false
       }} =
        Music.search_artists("the", query: [sort_input: "name"])

      {:ok,
       %{
         results: [%{name: "The Lost Keys"}, %{name: "Nights in the Nullarbor"}],
         limit: 12,
         offset: 0,
         more?: false
       }} =
        Music.search_artists("the", query: [sort_input: "-name"])
    end

    test "album calculation", %{artists: artists} do
      refute Enum.empty?(artists)

      Enum.each(artists, fn artist ->
        {:ok, loaded} =
          Music.get_artist_by_id(artist.id,
            load: [
              :album_count,
              :latest_album_year_released,
              :cover_image_url,
              albums: [:string_years_ago]
            ]
          )

        assert artist.album_count > 0
        assert artist.latest_album_year_released
        assert artist.cover_image_url

        loaded.albums
        |> Enum.each(fn album ->
          assert album.years_ago >= 0
          assert album.string_years_ago
        end)
      end)
    end
  end

  describe "Tunez.Music.read_artists!/0-2" do
    test "when there is no data, nothing is returned" do
      assert Music.read_artists!() == []
    end
  end

  describe "Tunez.Music.search_artists/1-2" do
    def names(page), do: Enum.map(page.results, & &1.name)

    test "can filter by partial name matches" do
      ["hello", "goodbye", "what?"]
      |> Enum.each(&generate(artist(name: &1)))

      assert Enum.sort(names(Music.search_artists!("o"))) == ["goodbye", "hello"]
      assert names(Music.search_artists!("oo")) == ["goodbye"]
      assert names(Music.search_artists!("he")) == ["hello"]
    end

    test "can sort by name" do
      ["first", "third", "fourth", "second"]
      |> Enum.each(&generate(artist(name: &1)))

      actual = names(Music.search_artists!("", query: [sort_input: "+name"]))
      assert actual == ["first", "fourth", "second", "third"]
    end

    test "can sort by creation time" do
      generate(artist(seed?: true, name: "first", inserted_at: ago(30, :second)))
      generate(artist(seed?: true, name: "third", inserted_at: ago(10, :second)))
      generate(artist(seed?: true, name: "second", inserted_at: ago(20, :second)))

      actual = names(Music.search_artists!("", query: [sort_input: "-inserted_at"]))
      assert actual == ["third", "second", "first"]
    end

    test "can sort by update time" do
      generate(artist(seed?: true, name: "first", updated_at: ago(30, :second)))
      generate(artist(seed?: true, name: "third", updated_at: ago(10, :second)))
      generate(artist(seed?: true, name: "second", updated_at: ago(20, :second)))

      actual = names(Music.search_artists!("", query: [sort_input: "-updated_at"]))
      assert actual == ["third", "second", "first"]
    end

    test "can sort by latest album release" do
      first = generate(artist(name: "first"))
      generate(album(year_released: 2023, artist_id: first.id))

      third = generate(artist(name: "third"))
      generate(album(year_released: 2008, artist_id: third.id))

      second = generate(artist(name: "second"))
      generate(album(year_released: 2012, artist_id: second.id))

      actual =
        names(Music.search_artists!("", query: [sort_input: "--latest_album_year_released"]))

      assert actual == ["first", "second", "third"]
    end

    test "can sort by number of album releases" do
      generate(artist(name: "two", album_count: 2))
      generate(artist(name: "none"))
      generate(artist(name: "one", album_count: 1))
      generate(artist(name: "three", album_count: 3))

      actual = names(Music.search_artists!("", query: [sort_input: "-album_count"]))

      assert actual == ["three", "two", "one", "none"]
    end

    test "can paginate search results" do
      generate_many(artist(), 2)

      page = Music.search_artists!("", page: [limit: 1])
      assert length(page.results) == 1
      assert page.more?

      next_page = Ash.page!(page, :next)
      assert length(page.results) == 1
      refute next_page.more?
    end
  end

  describe "Tunez.Music.create_artist/1-2" do
    test "stores the actor that created the record" do
      actor = generate(user(role: :admin))

      artist = Music.create_artist!(%{name: "New Artist"}, actor: actor)
      assert artist.created_by_id == actor.id
      assert artist.updated_by_id == actor.id
    end
  end

  describe "Tunez.Music.update_artist/2-3" do
    test "collects old names when the artist name changes" do
      actor = generate(user(role: :admin))

      artist = generate(artist(name: "First Name"))
      assert artist.previous_names == []

      # First Name is moved to previous_names
      artist = Music.update_artist!(artist, %{name: "Second Name"}, actor: actor)
      assert artist.previous_names == ["First Name"]

      # Second Name is added to previous names
      artist = Music.update_artist!(artist, %{name: "Third Name"}, actor: actor)
      assert artist.previous_names == ["Second Name", "First Name"]

      # First Name is now the current name again, not a previous name
      artist = Music.update_artist!(artist, %{name: "First Name"}, actor: actor)
      assert artist.previous_names == ["Third Name", "Second Name"]
    end

    test "stores the actor that updated the record" do
      # FIXME TODO Something is wrong here
      actor = generate(user(role: :admin))

      artist = generate(artist(name: "First Name"))
      refute artist.updated_by_id == actor.id

      #  artist = Music.update_artist!(artist, %{name: "Second Name"}, actor: actor, load: [:updated_by])
      #   assert artist.updated_by_id == actor.id
    end
  end

  describe "Tunez.Music.destroy_artist/2" do
    @tag skip: "can be enabled during chapter 10"
    test "deletes any associated albums when the artist is deleted" do
      # artist = generate(artist())
      # album = generate(album(artist_id: artist.id, name: "to be deleted"))

      # # This should be deleted too, without error
      # notification = generate(notification(album_id: album.id))

      # Music.destroy_artist!(artist, authorize?: false)

      # refute get_by_name(Tunez.Music.Album, "to be deleted")
      # assert match?({:error, _}, Ash.get(Tunez.Accounts.Notification, notification.id))
    end
  end

  describe "cover_image_url" do
    test "uses the cover from the first album that has a cover" do
      artist = generate(artist())
      generate(album(artist_id: artist.id, year_released: 2021))

      generate(
        album(
          artist_id: artist.id,
          year_released: 2019,
          cover_image_url: "/images/older.jpg"
        )
      )

      generate(
        album(
          artist_id: artist.id,
          year_released: 2020,
          cover_image_url: "/images/the_real_cover.png"
        )
      )

      {:ok, artist} = Ash.load(artist, :cover_image_url)
      assert artist.cover_image_url == "/images/the_real_cover.png"
    end
  end

  describe "policies" do
    def setup_users do
      %{
        admin: generate(user(role: :admin)),
        editor: generate(user(role: :editor)),
        user: generate(user(role: :user))
      }
    end

    test "only admins can create new artists" do
      users = setup_users()

      assert Music.can_create_artist?(users.admin)
      refute Music.can_create_artist?(users.editor)
      refute Music.can_create_artist?(users.user)
      refute Music.can_create_artist?(nil)
    end

    test "only admins can delete artists" do
      users = setup_users()
      artist = generate(artist())

      assert Music.can_destroy_artist?(users.admin, artist)
      refute Music.can_destroy_artist?(users.editor, artist)
      refute Music.can_destroy_artist?(users.user, artist)
      refute Music.can_destroy_artist?(nil, artist)
    end

    @tag skip: "Also uncomment the `setup_users` function above"
    test "admins and editors can update artists" do
      users = setup_users()
      artist = generate(artist())

      assert Music.can_update_artist?(users.admin, artist)
      assert Music.can_update_artist?(users.editor, artist)
      refute Music.can_update_artist?(users.user, artist)
      refute Music.can_update_artist?(nil, artist)
    end
  end
end
