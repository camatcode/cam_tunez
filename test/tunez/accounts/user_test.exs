defmodule Tunez.Accounts.UserTest do
  use Tunez.DataCase, async: false

  alias Ash.Error.Forbidden
  alias Tunez.Accounts.User

  @moduletag :capture_log

  describe "cam tests >" do
    test "auth actions" do
      eml = Faker.Internet.email()
      password = Faker.Internet.slug()
      password_confirm = password

      {:ok, user} =
        Ash.Changeset.for_create(
          User,
          :register_with_password,
          %{email: eml, password: password, password_confirmation: password_confirm}
        )
        |> Ash.create(authorize?: false)

      assert eml == user.email |> to_string()

      {:ok, [logged_in_user]} =
        Ash.Query.for_read(User, :sign_in_with_password, %{email: eml, password: password})
        |> Ash.read(authorize?: false)

      assert logged_in_user.id == user.id

      assert logged_in_user.__metadata__.token

      jwt_token = logged_in_user.__metadata__.token

      {:ok, %{"purpose" => "user", "sub" => subject} = _claims, resource} =
        AshAuthentication.Jwt.verify(jwt_token, :tunez)

      user_id = logged_in_user.id

      {:ok, %{id: ^user_id}} =
        AshAuthentication.subject_to_user(subject, resource)
    end

    test "policy" do
      eml = Faker.Internet.email()
      password = Faker.Internet.slug()
      password_confirm = password

      {:ok, user} =
        Ash.Changeset.for_create(
          User,
          :register_with_password,
          %{email: eml, password: password, password_confirmation: password_confirm}
        )
        |> Ash.create()

      assert user.email |> to_string() == eml
    end
  end
end
