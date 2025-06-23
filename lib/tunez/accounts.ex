defmodule Tunez.Accounts do
  use Ash.Domain,
    otp_app: :tunez

  alias Tunez.Accounts.Token
  alias Tunez.Accounts.User

  resources do
    resource Token
    resource User
  end
end
