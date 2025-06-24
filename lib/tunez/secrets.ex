defmodule Tunez.Secrets do
  @moduledoc "<p></p>"
  use AshAuthentication.Secret

  alias Tunez.Accounts.User

  def secret_for([:authentication, :tokens, :signing_secret], User, _opts, _context) do
    Application.fetch_env(:tunez, :token_signing_secret)
  end
end
