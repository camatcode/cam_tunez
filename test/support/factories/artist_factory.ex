defmodule Tunez.Factory.ArtistFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
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
        |> then(&Ash.Changeset.for_create(Artist, :create, &1))
        |> do_insert?(insert?, actor)
      end

      defp do_insert?(changeset, true, actor), do: Ash.create!(changeset, authorize?: false, actor: actor)

      defp do_insert?(changeset, _, _), do: changeset
    end
  end
end
