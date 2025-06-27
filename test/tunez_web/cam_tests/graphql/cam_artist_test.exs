defmodule TunezWeb.Graphql.CamArtistTest do
  use TunezWeb.ConnCase, async: true

  @moduletag :capture_log

  describe desc(:queries) do
    setup do
      artists =
        ["hello", "goodbye", "what?"]
        |> Enum.map(&build(:artist, name: &1, insert?: true))

      %{artists: artists}
    end

    test desc(:getArtistById), %{artists: _artists} do
      payload = """
      query searchArtists($query: String, $sort: [ArtistSortInput]) {
        searchArtists(query: $query, sort: $sort) {
          results {
          name}
        }
      }
      """

      variables = %{
        "query" => "o",
        "sort" => [%{"field" => "NAME", "order" => "ASC"}]
      }

      {:ok,
       %{
         data: %{
           "searchArtists" => %{
             "results" => [%{"name" => "goodbye"}, %{"name" => "hello"}]
           }
         }
       }} = Absinthe.run(payload, TunezWeb.GraphqlSchema, variables: variables)
    end
  end

  describe desc(:mutations) do
    setup do
      admin = build(:registered_user, role: :admin, insert?: true)
      artist = build(:artist, insert?: true)
      create = build_create()
      update = build_update(artist)
      %{create: create, update: update, admin: admin, artist: artist}
    end

    test desc("create via Absinthe"), %{
      admin: actor,
      create: %{
        payload: payload,
        variables: variables,
        artist_name: artist_name
      }
    } do
      {:ok,
       %{
         data: %{
           "createArtist" => %{
             "errors" => [],
             "result" => %{
               "name" => ^artist_name
             }
           }
         }
       }} =
        Absinthe.run(payload, TunezWeb.GraphqlSchema,
          variables: variables,
          context: %{actor: actor}
        )
    end

    test desc("create via HTTP"), %{
      conn: conn,
      admin: actor,
      create: %{
        payload: payload,
        variables: variables,
        artist_name: artist_name
      }
    } do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{actor.__metadata__.token}")
        |> post("/gql", %{"query" => payload, "variables" => variables})

      assert json_response(conn, 200) == %{
               "data" => %{
                 "createArtist" => %{
                   "errors" => [],
                   "result" => %{"name" => artist_name}
                 }
               }
             }
    end

    test desc(:update), %{
      admin: actor,
      artist: artist,
      update: %{payload: payload, variables: variables, artist_name: artist_name}
    } do
      {:ok,
       %{
         data: %{
           "updateArtist" => %{
             "errors" => [],
             "result" => %{"name" => ^artist_name}
           }
         }
       }} =
        Absinthe.run(payload, TunezWeb.GraphqlSchema,
          variables: variables,
          context: %{actor: actor}
        )
        |> IO.inspect()
    end

    test desc(:destroy), %{admin: actor, artist: artist} do
      payload = """
      mutation destroyArtist($id: ID!) {
        destroyArtist(id: $id) {
          result { name }
          errors { message }
        }
      }
      """

      variables = %{"id" => artist.id}
      artist_name = artist.name

      {:ok,
       %{
         data: %{
           "destroyArtist" => %{"errors" => [], "result" => %{"name" => ^artist_name}}
         }
       }} =
        Absinthe.run(payload, TunezWeb.GraphqlSchema,
          variables: variables,
          context: %{actor: actor}
        )
    end

    defp build_create do
      payload = """
      mutation createArtist($input: CreateArtistInput!) {
        createArtist(input: $input) {
          result { name }
          errors { message }
        }
      }
      """

      artist_name = Faker.Lorem.sentence()
      variables = %{"input" => %{"name" => artist_name}}

      %{payload: payload, variables: variables, artist_name: artist_name}
    end

    defp build_update(artist) do
      payload = """
      mutation updateArtist($id: ID! $input: UpdateArtistInput) {
        updateArtist(id: $id, input: $input) {
          result { name }
          errors { message }
        }
      }
      """

      artist_name = Faker.Lorem.sentence()
      variables = %{"id" => artist.id, "input" => %{"name" => artist_name}}
      %{payload: payload, variables: variables, artist_name: artist_name}
    end
  end
end
