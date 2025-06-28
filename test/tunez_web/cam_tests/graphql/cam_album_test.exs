defmodule TunezWeb.Graphql.CamAlbumTest do
  use TunezWeb.ConnCase, async: true

  @moduletag :capture_log

  describe desc(:mutations) do
    setup do
      admin = build(:registered_user, role: :admin, insert?: true)
      artist = build(:artist, insert?: true)
      album = build(:album, artist_id: artist.id, insert?: true)
      %{admin: admin, artist: artist, album: album}
    end

    test desc(:createAlbum), %{admin: actor, artist: artist} do
      payload = """
      mutation createAlbum($input: CreateAlbumInput!) {
        createAlbum(input: $input) {
          result { name }
          errors { message }
        }
      }
      """

      album_name = Faker.Lorem.sentence()

      variables = %{
        "input" => %{
          "artistId" => artist.id,
          "name" => album_name,
          "yearReleased" => 2022
        }
      }

      {:ok,
       %{
         data: %{
           "createAlbum" => %{"errors" => [], "result" => %{"name" => ^album_name}}
         }
       }} =
        Absinthe.run(
          payload,
          TunezWeb.GraphqlSchema,
          variables: variables,
          context: %{actor: actor}
        )
    end

    test desc(:updateAlbum), %{admin: actor, album: album} do
      payload = """
      mutation updateAlbum($id: ID! $input: UpdateAlbumInput) {
        updateAlbum(id: $id, input: $input) {
          result { name }
          errors { message }
        }
      }
      """

      new_album_name = Faker.Lorem.sentence()
      variables = %{"id" => album.id, "input" => %{"name" => new_album_name}}

      {:ok,
       %{
         data: %{
           "updateAlbum" => %{
             "errors" => [],
             "result" => %{"name" => ^new_album_name}
           }
         }
       }} =
        Absinthe.run(
          payload,
          TunezWeb.GraphqlSchema,
          variables: variables,
          context: %{actor: actor}
        )
    end

    test desc(:destroyAlbum), %{admin: actor, album: album} do
      payload =
        """
        mutation destroyAlbum($id: ID!) {
          destroyAlbum(id: $id) {
            result { name }
            errors { message }
          }
        }
        """

      album_name = album.name

      {:ok,
       %{
         data: %{
           "destroyAlbum" => %{
             "errors" => [],
             "result" => %{"name" => ^album_name}
           }
         }
       }} =
        Absinthe.run(payload, TunezWeb.GraphqlSchema,
          variables: %{"id" => album.id},
          context: %{actor: actor}
        )
    end
  end
end
