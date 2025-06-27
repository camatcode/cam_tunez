defmodule TunezWeb.Music.CamArtistTest do
  use Tunez.DataCase, async: false

  alias Ash.Error.Changes.Required
  alias Ash.Error.Invalid
  alias Tunez.Music, warn: false
  alias Tunez.Music.Artist

  @moduletag :capture_log

  describe desc(:iex) do
    setup do
      actor = build(:registered_user, role: :admin, insert?: true)

      artists =
        build_list(20, :artist, insert?: true, actor: actor)
        |> Enum.sort_by(& &1.name)

      albums =
        Enum.flat_map(artists, fn artist ->
          build_list(5, :album, insert?: true, actor: actor, artist_id: artist.id)
        end)

      %{admin: actor, artists: artists, albums: albums}
    end

    test desc(:create_via_changeset), %{admin: actor} do
      name = Faker.App.name()
      bio = Faker.Lorem.paragraph()

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

    test desc(:validation_pg_13), %{admin: actor} do
      {:error, %Invalid{errors: [%Required{field: :name}]}} =
        Ash.Changeset.for_create(Artist, :create, %{
          name: ""
        })
        |> Ash.create(actor: actor)
    end

    test desc(:create_artist), %{admin: actor} do
      name = Faker.App.name()
      bio = Faker.Lorem.paragraph()

      assert {:ok, %Artist{name: ^name, biography: ^bio}} =
               Music.create_artist(%{name: name, biography: bio}, actor: actor)
    end

    test desc(:read_artist), %{artists: artists} do
      {:ok, retrieved_artists} = Music.read_artists()
      to_find_ids = Enum.map(artists, & &1.id)
      found_ids = Enum.map(retrieved_artists, & &1.id)
      assert Enum.all?(to_find_ids, &Enum.member?(found_ids, &1))
    end

    test desc(:get_by_id), %{artists: artists} do
      Enum.each(artists, fn artist ->
        assert {:ok, found} = Music.get_artist_by_id(artist.id)
        assert found.id == artist.id
      end)
    end

    test desc(:update), %{artists: artists, admin: actor} do
      Enum.each(artists, fn %{id: id, name: _old_name} = artist ->
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

    test desc(:destroy), %{artists: artists, admin: actor} do
      Enum.each(artists, fn artist ->
        assert :ok = Music.destroy_artist(artist, actor: actor)
      end)
    end

    test desc(:album_calculation), %{artists: artists} do
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

  describe desc(:crud) do
    setup do
      actor = build(:registered_user, role: :admin, insert?: true)
      name = Faker.Lorem.sentence()
      {:ok, artist} = Music.create_artist(%{name: name}, actor: actor)
      %{admin: actor, artist: artist}
    end

    test desc(:create), %{admin: actor, artist: artist} do
      assert artist.created_by_id == actor.id
      assert artist.updated_by_id == actor.id
    end

    test desc(:update), %{admin: actor, artist: artist} do
      first_name = artist.name
      assert artist.previous_names == []

      second_name = Faker.Lorem.sentence()
      artist = Music.update_artist!(artist, %{name: second_name}, actor: actor)
      [^first_name] = artist.previous_names

      third_name = Faker.Lorem.sentence()
      artist = Music.update_artist!(artist, %{name: third_name}, actor: actor)
      [^second_name, ^first_name] = artist.previous_names

      artist = Music.update_artist!(artist, %{name: first_name}, actor: actor)
      [^third_name, ^second_name] = artist.previous_names

      assert artist.updated_by_id == actor.id
    end

    test desc(:cover_image_url), %{artist: artist} do
      build(:album, artist_id: artist.id, year_released: 2021, insert?: true)

      build(:album,
        artist_id: artist.id,
        year_released: 2019,
        cover_image_url: "/images/older.jpg",
        insert?: true
      )

      build(:album,
        artist_id: artist.id,
        year_released: 2020,
        cover_image_url: "/images/the_real_cover.png",
        insert?: true
      )

      {:ok, artist} = Ash.load(artist, :cover_image_url)
      assert artist.cover_image_url == "/images/the_real_cover.png"
    end
  end

  test desc(:policies) do
    admin = build(:registered_user, role: :admin, insert?: true)
    editor = build(:registered_user, role: :editor, insert?: true)
    user = build(:registered_user, insert?: true)
    artist = build(:artist, insert?: true)

    assert Music.can_create_artist?(admin)
    refute Music.can_create_artist?(editor)
    refute Music.can_create_artist?(user)
    refute Music.can_create_artist?(nil)

    assert Music.can_update_artist?(admin, artist)
    assert Music.can_update_artist?(editor, artist)
    refute Music.can_update_artist?(user, artist)
    refute Music.can_update_artist?(nil, artist)

    assert Music.can_destroy_artist?(admin, artist)
    refute Music.can_destroy_artist?(editor, artist)
    refute Music.can_destroy_artist?(user, artist)
    refute Music.can_destroy_artist?(nil, artist)
  end

  describe desc(:search) do
    def names(page), do: Enum.map(page.results, & &1.name)

    test desc(:filter_partial_name) do
      ["hello", "goodbye", "what?"]
      |> Enum.each(&build(:artist, name: &1, insert?: true))

      assert Enum.sort(names(Music.search_artists!("o"))) == ["goodbye", "hello"]
      assert names(Music.search_artists!("oo")) == ["goodbye"]
      assert names(Music.search_artists!("he")) == ["hello"]
    end

    test desc(:sort_by_name) do
      ["first", "third", "fourth", "second"]
      |> Enum.each(&build(:artist, name: &1, insert?: true))

      actual = names(Music.search_artists!("", query: [sort_input: "+name"]))
      assert actual == ["first", "fourth", "second", "third"]
    end

    test desc(:sort_by_insert) do
      generate(artist(seed?: true, name: "first", inserted_at: ago(30, :second)))
      generate(artist(seed?: true, name: "third", inserted_at: ago(10, :second)))
      generate(artist(seed?: true, name: "second", inserted_at: ago(20, :second)))

      actual = names(Music.search_artists!("", query: [sort_input: "-inserted_at"]))
      assert actual == ["third", "second", "first"]
    end

    test desc(:sort_by_update) do
      generate(artist(seed?: true, name: "first", updated_at: ago(30, :second)))
      generate(artist(seed?: true, name: "third", updated_at: ago(10, :second)))
      generate(artist(seed?: true, name: "second", updated_at: ago(20, :second)))

      ["third", "second", "first"] =
        names(Music.search_artists!("", query: [sort_input: "-updated_at"]))
    end

    test desc(:sort_by_album_release) do
      first = build(:artist, name: "first", insert?: true)

      _album_1 =
        build(:album, artist_id: first.id, year_released: 2023, insert?: true)

      second = build(:artist, name: "second", insert?: true)
      _album_2 = build(:album, artist_id: second.id, year_released: 2012, insert?: true)
      third = build(:artist, name: "third", insert?: true)
      _album_3 = build(:album, artist_id: third.id, year_released: 2008, insert?: true)

      ["first", "second", "third" | _] =
        names(Music.search_artists!("", query: [sort_input: "--latest_album_year_released"]))
    end

    test desc(:sort_by_num_albums) do
      two = build(:artist, name: "two", insert?: true)
      _two_albums = build_list(2, :album, artist_id: two.id, insert?: true)
      one = build(:artist, name: "one", insert?: true)
      _one_albums = build(:album, artist_id: one.id, insert?: true)
      three = build(:artist, name: "three", insert?: true)
      _three_albums = build_list(3, :album, artist_id: three.id, insert?: true)

      ["three", "two", "one" | _] =
        names(Music.search_artists!("", query: [sort_input: "-album_count"]))
    end

    test desc(:paginate) do
      build_list(2, :artist, insert?: true)
      page = Music.search_artists!("", page: [limit: 1])
      assert length(page.results) == 1
      assert page.more?

      next_page = Ash.page!(page, :next)
      assert length(page.results) == 1
      refute next_page.more?
    end
  end
end
