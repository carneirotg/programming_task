defmodule ProgrammingTask.ElasticHandler do
  # use Elastix
  use GenServer

  # server
  def init(config) do
    elastic_url =
      Application.get_env(:programming_task, :elastic_server_host) <>
        ":" <> Application.get_env(:programming_task, :elastic_server_port)

    config = %{
      elastic_url: elastic_url,
      elastic_index_name: Application.get_env(:programming_task, :elastic_index_name),
      elastic_doc_type: Application.get_env(:programming_task, :elastic_doc_type)
    }

    Elastix.Index.create(elastic_url, config.elastic_index_name, %{})
    {:ok, config}
  end

  def handle_cast({:put, mapping}, config) do
    Elastix.Mapping.put(
      config.elastic_url,
      config.elastic_index_name,
      config.elastic_doc_type,
      mapping
    )

    search_in = [config.elastic_doc_type]

    IO.inspect(
      Elastix.Search.search(config.elastic_url, config.elastic_index_name, search_in, %{})
    )

    {:noreply, config}
  end

  def start_link(state \\ []) do
    Elastix.start()
    config = %{}
    GenServer.start_link(__MODULE__, config, name: state)
  end

  # client
  def put(name, mapping) do
    GenServer.cast(name, {:put, mapping})
  end
end
