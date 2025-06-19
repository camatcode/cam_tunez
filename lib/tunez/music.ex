defmodule Tunez.Music do
  use Ash.Domain,
    otp_app: :tunez

  alias Tunez.Music.Artist

  resources do
    resource Artist
  end
end
