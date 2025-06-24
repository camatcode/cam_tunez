defmodule Tunez.Music.Artist do
  @moduledoc "<p></p>"
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Music,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    authorizers: [Ash.Policy.Authorizer]

  alias Tunez.Accounts.User
  alias Tunez.Music.Album
  alias Tunez.Music.Changes.UpdatePreviousNames

  graphql do
    type :artist

    filterable_fields [
      :album_count,
      :cover_image_url,
      :inserted_at,
      :latest_album_year_released,
      :updated_at
    ]
  end

  json_api do
    type "artist"
    includes [:albums]
    derive_filter? false
  end

  postgres do
    table "artists"
    repo Tunez.Repo

    custom_indexes do
      index "name gin_trgm_ops", name: "artists_name_gin_index", using: "GIN"
    end
  end

  resource do
    description "A person or some folks that make and release music"
  end

  actions do
    defaults [:create, :read, :destroy]
    default_accept [:name, :biography]

    update :update do
      require_atomic? false
      accept [:name, :biography]

      change UpdatePreviousNames, where: [changing(:name)]
    end

    read :search do
      description "Lists Artists, optionally filtering by name"

      argument :query, :ci_string do
        description "Return only Artists with names including the given value"
        constraints allow_empty?: true
        default ""
      end

      filter expr(contains(name, ^arg(:query)))
      pagination offset?: true, default_limit: 12

      # if you *always* wanted to load these properties
      # default_options was the route taken instead
      # prepare build(:load [:album_count, :latest_album_year_released, :cover_image_url])
    end
  end

  policies do
    policy action(:create) do
      authorize_if actor_attribute_equals(:role, :admin)
    end

    policy action(:update) do
      authorize_if actor_attribute_equals(:role, :admin)
      authorize_if actor_attribute_equals(:role, :editor)
    end

    policy action(:destroy) do
      authorize_if actor_attribute_equals(:role, :admin)
    end

    policy action_type(:read) do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :biography, :string do
      public? true
    end

    attribute :previous_names, {:array, :string} do
      default []
      public? true
    end

    create_timestamp :inserted_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    has_many :albums, Album do
      sort year_released: :desc
      public? true
    end

    belongs_to :created_by, User
    belongs_to :updated_by, User
  end

  calculations do
    # now an aggregate: calculate :album_count, :integer, expr(count(albums))
    # now an aggregate: calculate :latest_album_year_released, :integer, expr(first(albums, field: :year_released))
    # now an aggregate: calculate :cover_image_url, :string, expr(first(albums, field: :cover_image_url))
  end

  aggregates do
    count :album_count, :albums do
      public? true
    end

    first :latest_album_year_released, :albums, :year_released do
      public? true
    end

    first :cover_image_url, :albums, :cover_image_url
  end
end
