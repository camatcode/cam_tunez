defmodule Tunez.Accounts.CamUserTest do
  use Tunez.DataCase, async: false

  alias Tunez.Accounts.User

  @moduletag :capture_log

  test desc(:register_user) do
    # Register a user
    %{arguments: %{email: email}} =
      changeset = build(:registered_user)

    {:ok, user} = changeset |> Ash.create()

    assert user.email == email
  end

  test desc(:verify_user) do
    # register a user with a password
    %{arguments: %{email: email, password: password}} =
      changeset = build(:registered_user)

    {:ok, user} = changeset |> Ash.create(authorize?: false)

    # sign in that user
    {:ok, [logged_in_user]} =
      Ash.Query.for_read(User, :sign_in_with_password, %{email: email, password: password})
      |> Ash.read(authorize?: false)

    assert logged_in_user.id == user.id
    assert logged_in_user.__metadata__.token

    # Verify the JWT token
    jwt_token = logged_in_user.__metadata__.token

    {:ok, %{"purpose" => "user", "sub" => subject} = _claims, resource} =
      AshAuthentication.Jwt.verify(jwt_token, :tunez)

    user_id = logged_in_user.id

    {:ok, %{id: ^user_id}} =
      AshAuthentication.subject_to_user(subject, resource)
  end
end
