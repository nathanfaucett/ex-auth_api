# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :auth_api,
  ecto_repos: [AuthApi.Repo]

# Configures the endpoint
config :auth_api, AuthApi.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jKn4ilLLRg+wY940h75EqVfWfPfa/af5wCQcx7Gnsdv9ZoX1auu7aJg0C3/qCdOw",
  render_errors: [view: AuthApi.Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: AuthApi.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

{smtp_port, _} = Integer.parse(if System.get_env("SMTP_PORT") != nil do
  System.get_env("SMTP_PORT")
else
  "25"
end)

config :auth_api, AuthApi.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: System.get_env("SMTP_SERVER"),
  port: smtp_port,
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  tls: :if_available, # can be `:always` or `:never`
  ssl: false, # can be `true`
  retries: 1


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
