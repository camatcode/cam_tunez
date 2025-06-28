defmodule Tunez.Factory.ArtistFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def album_factory(attrs) do
      insert? = Map.get(attrs, :insert?, false)
      

      attrs =
        Map.delete(attrs, :role)
        |> Map.delete(:insert?)
        |> Map.delete(:actor)
        end

    end
  end
end
