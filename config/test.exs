use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :programming_task, ProgrammingTask.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :programming_task, ProgrammingTask.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "thiagocarneiro",
  password: "0606",
  database: "programming_task_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
