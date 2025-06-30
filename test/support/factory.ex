defmodule Tunez.Factory do
  @moduledoc false
  use ExMachina
  use Tunez.Factory.AlbumFactory
  use Tunez.Factory.ArtistFactory
  use Tunez.Factory.TrackFactory
  use Tunez.Factory.UserFactory
end
