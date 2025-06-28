defmodule TunezWeb.Music.CamAlbumTest do
  use Tunez.DataCase, async: true
  # use Oban.Testing, repo: Tunez.Repo
  alias Ash.Error.Invalid
  alias Tunez.Accounts.Notification, warn: false
  alias Tunez.Music, warn: false
  alias Tunez.Music.Album

  @moduletag :capture_log

  describe desc(:crud) do
    test desc(:create_album) do
      actor = build(:registered_user, insert?: true, role: :admin)
      artist = build(:artist, actor: actor, insert?: true)
      album = build(:album, actor: actor, artist_id: artist.id, insert?: true)

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

  describe desc(:validations) do
    setup do
      %{
        artist: build(:artist, insert?: true),
        admin: build(:registered_user, role: :admin, insert?: true)
      }
    end

    test desc(:year_released), %{artist: artist, admin: admin} do
      assert %{artist_id: artist.id, name: "test 2024", year_released: 2024}
             |> Music.create_album!(actor: admin)

      # # Using `assert_raise`
      assert_raise Invalid, ~r/must be between 1950 and next year/, fn ->
        %{artist_id: artist.id, name: "test 1925", year_released: 1925}
        |> Music.create_album!(actor: admin)
      end

      # # Using `assert_has_error` - note the lack of bang to return the error
      %{artist_id: artist.id, name: "test 1950", year_released: 1950}
      |> Music.create_album(actor: admin)
      |> Ash.Test.assert_has_error(Invalid, fn error ->
        match?(%{message: "must be between 1950 and next year"}, error)
      end)
    end

    test desc(:cover_image_url), %{artist: artist, admin: admin} do
      with_url = fn url ->
        Ash.Generator.action_input(Album, :create,
          artist_id: artist.id,
          year_released: 2025,
          cover_image_url: url
        )
        |> Enum.at(0)
      end

      assert Music.create_album!(with_url.("/images/test.jpg"), actor: admin)

      assert_raise Invalid, ~r/must start with/, fn ->
        Music.create_album!(with_url.("notavalidURL"), actor: admin)
      end

      with_url.("/image/tunez.mp3")
      |> Music.create_album(actor: admin)
      |> assert_has_error(fn error ->
        error.field == :cover_image_url &&
          error.message == "must start with https:// or /images/"
      end)
    end
  end
end
