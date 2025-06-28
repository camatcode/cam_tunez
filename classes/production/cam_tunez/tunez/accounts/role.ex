defmodule Tunez.Accounts.Role do
  @moduledoc """
  The permissions of a User
  """
  use Ash.Type.Enum, values: [:admin, :editor, :user]
end
