defmodule TunezWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides

  # configure your UI overrides here

  # First argument to `override` is the component name you are overriding.
  # The body contains any number of configurations you wish to override
  # Below are some examples

  alias AshAuthentication.Phoenix.Components
  # For a complete reference, see https://hexdocs.pm/ash_authentication_phoenix/ui-overrides.html
  alias AshAuthentication.Phoenix.Components.Password.Input.Input

  override Input do
    set :submit_class, "bg-primary-600 text-white my-4 py-3 px-5 text-sm"
  end

  override Components.Banner do
    set :image_url, nil
    set :dark_image_url, nil
    set :text_class, "text-4xl text-accent-400"
    set :text, "♫ CamTunez"
  end

  override Components.SignIn do
    set :show_banner, true

    set :root_class,
        "text-accent-400 flex-1 flex-col justify-center py-12 px-4 sm:px-6 lg:flex-none lg:px-20 xl:px-24"
  end

  override Components.MagicLink do
    set :request_flash_text, "Check your email for a sign-in link!"
  end
end
