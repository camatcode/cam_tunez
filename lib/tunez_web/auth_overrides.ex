defmodule TunezWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides

  # configure your UI overrides here

  # First argument to `override` is the component name you are overriding.
  # The body contains any number of configurations you wish to override
  # Below are some examples

  # For a complete reference, see https://hexdocs.pm/ash_authentication_phoenix/ui-overrides.html
  alias AshAuthentication.Phoenix.Components.Banner
  alias AshAuthentication.Phoenix.Components.SignIn

  # override Banner do
  #  set :image_url, "https://media.giphy.com/media/g7GKcSzwQfugw/giphy.gif"
  #  set :text_class, "bg-red-500"
  # remove the in-between "flex"
  # set :root_class, "flex-1 flex-col justify-center py-12 px-4 sm:px-6 lg:flex-none lg:px-20 xl:px-24"
  # end

  # override SignIn do
  # set :show_banner, false
  # end
end
