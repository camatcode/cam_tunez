import Config

alias Swoosh.Adapters.Test

config :bcrypt_elixir, log_rounds: 1

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :phoenix_test, :endpoint, TunezWeb.Endpoint

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Configure your database
#

# In test we don't send emails
# The MIX_TEST_PARTITION environment variable can be used

# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :tunez, Tunez.Mailer, adapter: Test

config :tunez, Tunez.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "tunez_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  # We don't run a server during test. If one is required,
  # you can enable the server option below.
  pool_size: System.schedulers_online() * 2

config :tunez, TunezWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "juvWYF54fW6O46xWjNKvoSyt24rsG4J6/T0bv1YgNqVwRSxCqGj7Qumm1G0seN74",
  server: false

config :tunez, token_signing_secret: "5NSiCb+BrW5SH2F8yl/rpSQ0L9FwZVhj"

config :ash_authentication, debug_authentication_failures?: true
config :ash, :policies, show_policy_breakdowns?: true
