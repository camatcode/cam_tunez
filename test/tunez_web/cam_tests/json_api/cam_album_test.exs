defmodule TunezWeb.JsonApi.CamAlbumTest do
  use TunezWeb.ConnCase, async: true

  import AshJsonApi.Test

  @moduletag :capture_log

  describe desc(:crud) do
    setup do
      admin = build(:registered_user, role: :admin, insert?: true)
      artist = build(:artist, insert?: true)
      album = build(:album, artist_id: artist.id, year_released: 1990, insert?: true)
      %{admin: admin, artist: artist, album: album}
    end

    test desc(:create), %{admin: actor, artist: artist} do
      album_name = Faker.Lorem.sentence()

      post(
        Tunez.Music,
        "/albums",
        %{
          data: %{
            attributes: %{artist_id: artist.id, name: album_name, year_released: 2015}
          }
        },
        router: TunezWeb.AshJsonApiRouter,
        status: 201,
        actor: actor
      )
      |> assert_data_matches(%{
        "attributes" => %{"name" => ^album_name}
      })
    end

    test desc(:read), %{artist: artist, album: album} do
      album_2 = build(:album, artist_id: artist.id, year_released: 1970, insert?: true)

      a_1_name = album.name
      a_2_name = album_2.name

      get(
        Tunez.Music,
        "/artists/#{artist.id}/albums",
        router: TunezWeb.AshJsonApiRouter,
        status: 200
      )
      |> assert_data_matches([
        %{"attributes" => %{"name" => ^a_1_name}},
        %{"attributes" => %{"name" => ^a_2_name}}
      ])
    end

    test desc(:update), %{admin: actor, album: album} do
      updated_name = Faker.Lorem.sentence()

      patch(
        Tunez.Music,
        "/albums/#{album.id}",
        %{
          data: %{
            attributes: %{name: updated_name, year_released: 2001}
          }
        },
        router: TunezWeb.AshJsonApiRouter,
        status: 200,
        actor: actor
      )
      |> assert_data_matches(%{
        "attributes" => %{"name" => ^updated_name}
      })
    end

    test desc(:destroy), %{admin: actor, album: album} do
      album_name = album.name

      delete(
        Tunez.Music,
        "/albums/#{album.id}",
        router: TunezWeb.AshJsonApiRouter,
        status: 200,
        actor: actor
      )
      |> assert_data_matches(%{
        "attributes" => %{"name" => ^album_name}
      })
    end
  end
end
