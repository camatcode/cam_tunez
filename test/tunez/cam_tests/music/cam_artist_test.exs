defmodule TunezWeb.Music.CamArtistTest do
  use Tunez.DataCase, async: false

  alias Ash.Error.Changes.Required
  alias Ash.Error.Invalid
  alias Tunez.Music, warn: false
  alias Tunez.Music.Artist

  @moduletag :capture_log

  describe desc(:iex_tests) do
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

    test desc(:manual_query), %{artists: [artist | _]} do
      query =
        Ash.Query.for_read(Artist, :read)
        |> Ash.Query.sort(name: :asc)
        |> Ash.Query.limit(1)

      assert {:ok, [found]} = Ash.read(query)
      assert found.id == artist.id
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

  
end
