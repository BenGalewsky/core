use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :core, Core.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database

config :core, Core.Repo,
    adapter: Ecto.Adapters.Postgres,
    username: "postgres",
    password: "foobar",
    database: "core",
    hostname: "localhost",
    pool: Ecto.Adapters.SQL.Sandbox

config :core, Core.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  api_key: System.get_env("MAILGUN_KEY"),
  domain: System.get_env("MAILGUN_DOMAIN")


config :core, Core.Vox,
  adapter: Swoosh.Adapters.Mailgun,
  api_key: System.get_env("MAILGUN_KEY"),
  domain: System.get_env("MAILGUN_DOMAIN")

# Redis url
config :core, [redis_url: System.get_env("REDIS_URL")]

config :core, :relay_api, Relay.MockAPI

