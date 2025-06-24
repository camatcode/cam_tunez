defmodule Tunez.Accounts do
  @moduledoc "<p></p>"
  use Ash.Domain, otp_app: :tunez, extensions: [AshGraphql.Domain, AshJsonApi.Domain]

  alias Tunez.Accounts.Token
  alias Tunez.Accounts.User

  graphql do
    queries do
      get User, :sign_in_user, :sign_in_with_password do
        identity false
        type_name :user_with_token
      end
    end
  end

  json_api do
    routes do
      base_route "/users", User do
        post :register_with_password do
          route "/register"

          metadata fn _subject, user, _request ->
            %{token: user.__metadata__.token}
          end
        end

        post :sign_in_with_password do
          route "/sign-in"

          metadata fn _subject, user, _request ->
            %{token: user.__metadata__.token}
          end
        end
      end
    end
  end

  resources do
    resource Token

    resource User do
      define :set_user_role, action: :set_role, args: [:role]
      define :get_user_by_id, action: :read, get_by: [:id]
    end
  end
end
