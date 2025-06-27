defmodule Tunez.Factory.ArtistFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Tunez.Music.Album

      def album_factory(attrs) do
      end
    end
  end
end
