defmodule Tunez.Factory.AlbumFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Tunez.Music
      alias Tunez.Music.Album

      def album_factory(attrs) do
        insert? = Map.get(attrs, :insert?, false)
        actor = Map.get(attrs, :actor, build(:registered_user, role: :admin, insert?: true))

        attrs =
          Map.delete(attrs, :role)
          |> Map.delete(:insert?)
          |> Map.delete(:actor)

        year_released = Enum.random(1951..2024)
        artist_id = build(:artist, insert?: true).id

        %{
          name: Faker.Lorem.sentence(1)<> "_#{System.monotonic_time()}",
          year_released: year_released,
          artist_id: artist_id
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
        |> do_insert_album?(insert?, actor)
      end

      defp do_insert_album?(params, true, actor) do
        Music.create_album!(
          params,
          actor: actor
        )
      end

      defp do_insert_album?(params, _, _), do: params
    end
  end
end
