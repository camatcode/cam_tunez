defmodule Tunez.Music do
  use Ash.Domain, otp_app: :tunez, extensions: [AshGraphql.Domain, AshJsonApi.Domain, AshPhoenix]

  alias Tunez.Music.Album
  alias Tunez.Music.Artist

  graphql do
    queries do
      get Artist, :get_artist_by_id, :read
      list Artist, :search_artists, :search
    end

    mutations do
      create Artist, :create_artist, :create
      update Artist, :update_artist, :update
      destroy Artist, :destroy_artist, :destroy

      create Album, :create_album, :create
      update Album, :update_album, :update
      destroy Album, :destroy_album, :destroy
    end
  end

  json_api do
    routes do
      base_route "/artists", Artist do
        get :read
        index :search
        post :create
        patch :update
        delete :destroy
        related :albums, :read, primary?: true
      end

      base_route "/albums", Album do
        post :create
        patch :update
        delete :destroy
      end
    end
  end

  forms do
    form :create_album, args: [:artist_id]
  end

  resources do
    resource Artist do
      define :create_artist, action: :create
      define :read_artists, action: :read
      define :get_artist_by_id, action: :read, get_by: :id

      define :search_artists,
        action: :search,
        args: [:query],
        default_options: [load: [:album_count, :latest_album_year_released, :cover_image_url]]

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
