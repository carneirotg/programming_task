# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :programming_task,
  elastic_server_host: "http://127.0.0.1",
  elastic_server_port: "9200",
  elastic_index_name: "sensor_message_average",
  elastic_doc_type: "sensor_message"

# Configures the endpoint
config :programming_task, ProgrammingTask.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "f0AXPXi6xl3b6QojvpQjJuF5BJl1/bzxdw/0KwNYMt+6Zm6oJba5VEUfu9e9nXCN",
  # render_errors: [view: ProgrammingTask.ErrorView, accepts: ~w(json)],
  pubsub: [name: ProgrammingTask.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
