defmodule Tunez.Factory.ArtistFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Tunez.Music
      alias Tunez.Music.Artist

      def artist_factory(attrs) do
        insert? = Map.get(attrs, :insert?, false)
        actor = Map.get(attrs, :actor, build(:registered_user, role: :admin, insert?: true))

        attrs =
          Map.delete(attrs, :role)
          |> Map.delete(:insert?)
          |> Map.delete(:actor)

        %{name: Faker.App.name(), biography: Faker.Lorem.paragraph()}
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
        |> do_insert_artist?(insert?, actor)
      end

      defp do_insert_artist?(params, true, actor) do
        Music.create_artist!(
          params,
          actor: actor
        )
      end

      defp do_insert_artist?(params, _, _), do: params
    end
  end
end
