defmodule TunezWeb.AshJsonApiRouter do
  @moduledoc Tunez.Doc.dummy()
  use AshJsonApi.Router,
    domains: [Tunez.Music, Tunez.Accounts],
    open_api: "/open_api",
    open_api_title: "Tunez API Documentation",
    open_api_version: Application.spec(:tunez, :vsn) |> to_string()
end
