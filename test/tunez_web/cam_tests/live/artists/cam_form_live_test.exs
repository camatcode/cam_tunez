defmodule TunezWeb.Artists.CamFormLiveTest do
  use TunezWeb.ConnCase, async: true

  alias Ash.Error.Forbidden
  #  alias Tunez.Accounts.User
  alias Tunez.Music, warn: false
  alias Tunez.Music.Artist

  @moduletag :capture_log

  describe desc(:iex_tests) do
    setup do
      admin = build(:registered_user, role: :admin, insert?: true)
      %{admin: admin}
    end

    test desc("a form in action"), %{admin: actor} do
      name = "Best Band Ever"

      form = AshPhoenix.Form.for_create(Artist, :create, actor: actor)

      validation = AshPhoenix.Form.validate(form, %{name: name})
      assert validation.source.valid?

      AshPhoenix.Form.submit(form, params: %{name: name}, actor: actor)

      name = Faker.Person.name()
      form = Music.form_to_create_artist(actor: actor)
      validation = AshPhoenix.Form.validate(form, %{name: name})
      assert validation.source.valid?

      assert {:ok, %Artist{name: ^name}} =
               AshPhoenix.Form.submit(form, params: %{name: name}, actor: actor)
    end
  end

  describe desc(:crud) do
    setup %{conn: conn} do
      user = build(:registered_user, insert?: true)
      admin = build(:registered_user, role: :admin, insert?: true)
      %{conn: conn, user: user, admin: admin}
    end

    test desc(:deny), %{conn: conn, user: user} do
      assert_raise(Forbidden, fn ->
        log_in_user(conn, user)
        |> visit(~p"/artists/new")
      end)
    end

    test desc(:create), %{conn: _conn, admin: _user} do
      #      log_in_user(conn, user)
      #      |> visit(~p"/artists/new")
      #      |> fill_in("Name", with: "Temperance")
      #      |> click_button("Save")
      #      |> assert_has(flash(:info), text: "Artist saved successfully")
      #
      #      assert get_by_name(Artist, "Temperance")
    end
  end
end
