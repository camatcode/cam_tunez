defmodule Tunez.Accounts do
  use Ash.Domain, otp_app: :tunez, extensions: [AshJsonApi.Domain]

  alias Tunez.Accounts.Token
  alias Tunez.Accounts.User

  json_api do
    routes do
      base_route "/users", User do
        post :register_with_password, route: "/register"
      end
    end
  end

  resources do
    resource Token
    resource User
  end
end
