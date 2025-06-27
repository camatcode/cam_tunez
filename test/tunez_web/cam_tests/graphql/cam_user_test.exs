defmodule TunezWeb.Graphql.CamUserTest do
  use TunezWeb.ConnCase, async: true

  @moduletag :capture_log

  describe desc(:queries) do
    test desc(:sign_in_user) do
      password = Faker.Lorem.sentence()
      user = build(:registered_user, password: password, insert?: true)

      payload = """
      query signInUser($email: String!, $password: String!) {
        signInUser(email: $email, password: $password) {
          id
          token
        }
      }
      """

      variables = %{"email" => user.email |> to_string(), "password" => password}
      user_id = user.id

      {:ok,
       %{
         data: %{
           "signInUser" => %{
             "id" => ^user_id,
             "token" => token
           }
         }
       }} = Absinthe.run(payload, TunezWeb.GraphqlSchema, variables: variables)

      assert token
    end
  end

  describe desc(:mutations) do
    test desc(:register_user) do
      payload = """
      mutation registerUser($input: RegisterUserInput!) {
        registerUser(input: $input) {
          errors { message }
          metadata { token }
          result { id }
        }
      }
      """

      variables = %{
        "input" => %{
          "email" => "test2@test.com",
          "password" => "password2",
          "passwordConfirmation" => "password2"
        }
      }

      {:ok,
       %{
         data: %{
           "registerUser" => %{
             "errors" => [],
             "metadata" => %{
               "token" => token
             },
             "result" => %{"id" => user_id}
           }
         }
       }} =
        Absinthe.run(payload, TunezWeb.GraphqlSchema, variables: variables)

      assert user_id
      assert token
    end
  end
end
