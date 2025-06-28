defmodule TunezWeb.JsonApi.CamArtistTest do
  use TunezWeb.ConnCase, async: true

  import AshJsonApi.Test

  @moduletag :capture_log

  describe desc(:crud) do
    setup do
      admin = build(:registered_user, role: :admin, insert?: true)

      artists = build_list(10, :artist, insert?: true)

      albums =
        Enum.flat_map(artists, fn artist ->
          build_list(Enum.random(1..10), :album, artist_id: artist.id, insert?: true)
        end)

      %{admin: admin, artists: artists, albums: albums}
    end

    test desc(:read_by_id), %{artists: artists} do
      refute Enum.empty?(artists)

      Enum.each(artists, fn artist ->
        name = artist.name

        get(
          Tunez.Music,
          "/artists/#{artist.id}",
          router: TunezWeb.AshJsonApiRouter,
          status: 200
        )
        |> assert_data_matches(%{
          "attributes" => %{"name" => ^name}
        })
      end)
    end

    test desc(:search), _state do
      data =
        get(
          Tunez.Music,
          "/artists?sort=-name&query=&fields=name,album_count",
          router: TunezWeb.AshJsonApiRouter,
          status: 200
        ).resp_body["data"]

      refute Enum.empty?(data)

      Enum.each(data, fn %{"attributes" => attrs} ->
        assert attrs["album_count"]
        assert attrs["name"]
      end)
    end

    test desc(:create), %{admin: actor} do
      name = Faker.Lorem.sentence()

      post(
        Tunez.Music,
        "/artists",
        %{
          data: %{
            attributes: %{name: name}
          }
        },
        router: TunezWeb.AshJsonApiRouter,
        status: 201,
        actor: actor
      )
      |> assert_data_matches(%{
        "attributes" => %{"name" => ^name}
      })
    end

    test desc(:update), %{admin: actor, artists: [artist | _]} do
      updated = Faker.Lorem.sentence()

      patch(
        Tunez.Music,
        "/artists/#{artist.id}",
        %{
          data: %{
            attributes: %{name: updated}
          }
        },
        router: TunezWeb.AshJsonApiRouter,
        status: 200,
        actor: actor
      )
      |> assert_data_matches(%{
        "attributes" => %{"name" => ^updated}
      })
    end

    test desc(:delete), %{admin: actor, artists: [artist | _]} do
      name = artist.name

      delete(
        Tunez.Music,
        "/artists/#{artist.id}",
        router: TunezWeb.AshJsonApiRouter,
        status: 200,
        actor: actor
      )
      |> assert_data_matches(%{
        "attributes" => %{"name" => ^name}
      })
    end
  end
end
