defmodule TunezWeb.Music.CamAlbumTest do
  use Tunez.DataCase, async: true
  # use Oban.Testing, repo: Tunez.Repo
  #  alias Ash.Error.Invalid
  alias CamAlbum
  alias Tunez.Accounts.Notification, warn: false
  alias Tunez.Music, warn: false
  #  alias Tunez.Music.Album

  @moduletag :capture_log

  describe desc(:crud) do
    test desc(:create_album) do
      actor = build(:registered_user, insert?: true, role: :admin)
      artist = build(:artist, actor: actor, insert?: true)

      album =
        Music.create_album!(
          %{name: "New Album", artist_id: artist.id, year_released: 2024},
          actor: actor
        )

      assert album.created_by_id == actor.id
      assert album.updated_by_id == actor.id
    end

    test desc(:update_album) do
      actor = build(:registered_user, insert?: true, role: :admin)
      album = build(:album, insert?: true)
      refute album.updated_by_id == actor.id

      album = Music.update_album!(album, %{name: "The New Name"}, actor: actor)
      assert album.updated_by_id == actor.id
    end
  end
end
