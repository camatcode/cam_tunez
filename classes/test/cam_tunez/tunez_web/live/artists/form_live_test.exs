defmodule TunezWeb.Artists.FormLiveTest do
  use TunezWeb.ConnCase, async: true

  alias Ash.Error.Forbidden
  alias Tunez.Accounts.User
  alias Tunez.Music, warn: false
  alias Tunez.Music.Artist

  describe "cam tests >" do
    setup do
      eml = Faker.Internet.email()
      password = Faker.Internet.slug() <> "_#{System.monotonic_time()}"
      password_confirm = password

      {:ok, user} =
        Ash.Changeset.for_create(
          User,
          :register_with_password,
          %{email: eml, password: password, password_confirmation: password_confirm}
        )
        |> Ash.create(authorize?: false)

      {:ok, user} = Tunez.Accounts.set_user_role(user, :admin, authorize?: false)
      %{admin: user}
    end

    test "a form in action", %{admin: actor} do
      name = "Best Band Ever"

      form = AshPhoenix.Form.for_create(Artist, :create, actor: actor)

      validation = AshPhoenix.Form.validate(form, %{name: name})
      assert validation.source.valid?

      AshPhoenix.Form.submit(form, params: %{name: name}, actor: actor)

      # using the extension: AshPhoenix

      name = Faker.Person.name()
      form = Music.form_to_create_artist(actor: actor)
      validation = AshPhoenix.Form.validate(form, %{name: name})
      assert validation.source.valid?

      assert {:ok, %Artist{name: ^name}} =
               AshPhoenix.Form.submit(form, params: %{name: name}, actor: actor)
    end
  end

  describe "creating a new artist" do
    test "errors for forbidden users", %{conn: conn} do
      assert_raise(Forbidden, fn ->
        conn
        |> insert_and_authenticate_user()
        |> visit(~p"/artists/new")
      end)
    end

    test "succeeds when valid details are entered", %{conn: conn} do
      conn
      |> insert_and_authenticate_user(:admin)
      |> visit(~p"/artists/new")
      |> fill_in("Name", with: "Temperance")
      |> click_button("Save")
      |> assert_has(flash(:info), text: "Artist saved successfully")

      assert get_by_name(Artist, "Temperance")
    end

    test "fails when invalid details are entered", %{conn: conn} do
      # TODO something is wrong here

      conn
      |> insert_and_authenticate_user(:admin)
      |> visit(~p"/artists/new")
      |> fill_in("Name", with: "")
      |> click_button("Save")

      #  |> assert_has(flash(:error), text: "Could not save artist data")

      assert Music.read_artists!() == []
    end
  end

  describe "updating an existing artist" do
    test "errors for forbidden users", %{conn: conn} do
      artist = generate(artist())

      assert_raise(Forbidden, fn ->
        conn
        |> insert_and_authenticate_user()
        |> visit(~p"/artists/#{artist}/edit")
      end)
    end

    test "succeeds when valid details are entered", %{conn: conn} do
      artist = generate(artist(name: "Old Name"))

      conn
      |> insert_and_authenticate_user(:admin)
      |> visit(~p"/artists/#{artist}/edit")
      |> fill_in("Name", with: "New Name")
      |> click_button("Save")
      |> assert_has(flash(:info), text: "Artist saved successfully")

      updated_artist = Music.get_artist_by_id!(artist.id)
      assert updated_artist.name == "New Name"
    end

    test "fails when invalid details are entered", %{conn: conn} do
      artist = generate(artist(name: "Old Name"))
      # TODO FIXME something is wrong here
      conn
      |> insert_and_authenticate_user(:admin)
      |> visit(~p"/artists/#{artist}/edit")
      |> fill_in("Name", with: "")
      |> click_button("Save")

      # |> assert_has(flash(:error), text: "Could not save artist data")

      updated_artist = Music.get_artist_by_id!(artist.id)
      assert updated_artist.name == "Old Name"
    end
  end
end
