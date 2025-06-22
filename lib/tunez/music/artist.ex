defmodule Tunez.Music.Artist do
  use Ash.Resource, otp_app: :tunez, domain: Tunez.Music, data_layer: AshPostgres.DataLayer

  alias Tunez.Music.Album

  postgres do
    table "artists"
    repo Tunez.Repo
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:name, :biography]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :biography, :string

    attribute :previous_names, {:array, :string} do
      default []
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :albums, Album do
      sort year_released: :desc
    end
  end
end
