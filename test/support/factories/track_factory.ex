defmodule Tunez.Factory.TrackFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def track_factory(attrs) do
        attrs =
          Map.delete(attrs, :role)
          |> Map.delete(:insert?)
          |> Map.delete(:actor)

        %{
          order: Enum.random(1..10),
          name: Faker.Lorem.sentence(),
          duration_seconds: Enum.random(1..100)
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
