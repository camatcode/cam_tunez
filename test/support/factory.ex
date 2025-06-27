defmodule Tunez.Factory do
  @moduledoc false
  use ExMachina
  use Tunez.Factory.ArtistFactory
  use Tunez.Factory.UserFactory
end
