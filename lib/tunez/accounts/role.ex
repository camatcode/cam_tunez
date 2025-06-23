defmodule Tunez.Accounts.Role do
  @moduledoc false
  use Ash.Type.Enum, values: [:admin, :editor, :user]
end
