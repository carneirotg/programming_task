defmodule ProgrammingTask.Router do
  use ProgrammingTask.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ProgrammingTask do
    pipe_through :api

    post "/measurements", SensorMessageController, :create
  end
end
