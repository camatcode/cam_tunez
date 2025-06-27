defmodule Tunez.Factory.UserFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Tunez.Accounts.User

      def registered_user_factory(attrs) do
        password = attrs[:password] || Faker.Lorem.sentence()
        role = Map.get(attrs, :role, :user)
        insert? = Map.get(attrs, :insert?, false)

        attrs =
          Map.delete(attrs, :role)
          |> Map.delete(:insert?)

        %{
          email: Faker.Internet.email(),
          password: password,
          password_confirmation: password
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
        |> then(&Ash.Changeset.for_create(User, :register_with_password, &1))
        |> do_insert_user?(insert?)
        |> handle_role(role)
      end

      defp do_insert_user?(changeset, true), do: Ash.create!(changeset, authorize?: false)
      defp do_insert_user?(changeset, _), do: changeset

      defp handle_role(obj, :user), do: obj

      defp handle_role(%User{} = u, role) do
        Tunez.Accounts.set_user_role!(u, role, authorize?: false)
      end

      defp handle_role(obj, _), do: obj
    end
  end
end
