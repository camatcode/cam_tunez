defmodule Tunez.Music do
  use Ash.Domain, otp_app: :tunez, extensions: [AshPhoenix]

  alias Tunez.Music.Album
  alias Tunez.Music.Artist

  forms do
    form :create_album, args: [:artist_id]
  end

  resources do
    resource Artist do
      define :create_artist, action: :create
      define :read_artists, action: :read
      define :get_artist_by_id, action: :read, get_by: :id
      define :search_artists, action: :search, args: [:query]
      define :update_artist, action: :update
      define :destroy_artist, action: :destroy
    end

    resource Album do
      define :create_album, action: :create
      define :get_album_by_id, action: :read, get_by: :id
      define :update_album, action: :update
      define :destroy_album, action: :destroy
    end
  end
end
