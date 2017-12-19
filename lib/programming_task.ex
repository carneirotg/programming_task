defmodule ProgrammingTask do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(ProgrammingTask.Endpoint, []),
      #Start the ElasticSearch server when the application starts.
      #The configuration for Elastic server will be on this module.
      worker(ProgrammingTask.ElasticHandler, [ELASTIC], [name: ELASTIC]),
      #Queues to receive and process the messages received from the controller
      worker(ProgrammingTask.SensorMessageQueue, [AGT_1], [id: AGT_1, name: AGT_1]),
      worker(ProgrammingTask.SensorMessageQueue, [AGT_2], [id: AGT_2, name: AGT_2]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ProgrammingTask.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ProgrammingTask.Endpoint.config_change(changed, removed)
    :ok
  end
end
