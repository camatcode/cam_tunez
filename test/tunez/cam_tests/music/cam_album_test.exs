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

  describe desc(:policies) do
    setup do
      %{
        admin: build(:registered_user, role: :admin, insert?: true),
        editor: build(:registered_user, role: :editor, insert?: true),
        user: build(:registered_user, insert?: true),
        album: build(:album, insert?: true)
      }
    end

    test desc(:crud_policies), %{
      admin: admin,
      editor: editor,
      user: user,
      album: album
    } do
      # create
      assert Music.can_create_album?(admin)
      assert Music.can_create_album?(editor)
      refute Music.can_create_album?(user)
      refute Music.can_create_album?(nil)

      # update
      assert Music.can_update_album?(admin, album)
      refute Music.can_update_album?(user, album)
      refute Music.can_update_album?(nil, album)

      # destroy
      assert Music.can_destroy_album?(admin, album)
      refute Music.can_destroy_album?(user, album)
      refute Music.can_destroy_album?(nil, album)
    end

    test desc(:editor_policy), %{
      editor: editor,
      album: cant_edit
    } do
      can_edit = build(:album, actor: editor, insert?: true)
      assert Music.can_update_album?(editor, can_edit)
      refute Music.can_update_album?(editor, cant_edit)

      assert Music.can_destroy_album?(editor, can_edit)
      refute Music.can_destroy_album?(editor, cant_edit)
    end
  end
end
