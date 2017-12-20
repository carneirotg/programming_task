defmodule ProgrammingTask.SensorMessageQueue do
  use GenServer

  alias ProgrammingTask.ElasticHandler

  @scheduled_time 5000

  # server
  def init(queue) do
    schedule_write_to_elastic()
    {:ok, queue}
  end

  def handle_cast({:enqueue, value}, queue) do

    case queue.first.time do
      nil ->
        queue =
          queue
          |> put_in([:sensor_id], value.sensor_id)
          |> put_in([:first, :index], 0)
          |> put_in([:first, :time], value.created_time)
          |> put_in([:last, :time], value.created_time)
          |> put_in([:count], 1)
          |> put_in([:elements], [value | queue.elements])

      _ ->
      queue =
        queue
        |> put_in([:last, :time], value.created_time)
        # |> put_in([:last, :index], length(queue.elements))
        |> put_in([:elements], [value | queue.elements])
        |> put_in([:count], queue.count + 1)
    end

    {:noreply, queue}
  end

  def handle_info(:write, queue) do
    window = queue
    if not is_nil(window.first.time) do
      if DateTime.diff(window.last.time, window.first.time) >= 60 do
        sliced_window = Enum.slice(window.elements, 0, window.count)
        body = %{
          start: DateTime.to_iso8601(window.first.time, :extended),
          end: DateTime.to_iso8601(window.last.time, :extended),
          sensorId: window.sensor_id,
          avg: average(sliced_window)
        }
        post_to_elastic(body)
      end
    end


    schedule_write_to_elastic()
    {:noreply, queue}
  end

  def post_to_elastic(params) do
    ElasticHandler.put(ELASTIC, params)
  end

  ### Client API / Helper functions

  def start_link(state \\ []) do
    queue = %{first: %{time: nil, index: nil}, last: %{time: nil, index: nil}, elements: [], count: 0, sensor_id: nil}
    GenServer.start_link(__MODULE__, queue, name: state)
  end

  defp schedule_write_to_elastic do
    # 5 seconds
    Process.send_after(self(), :write, @scheduled_time)
  end

  def enqueue(value, name) do
     GenServer.cast(name, {:enqueue, value})
  end

  def average(elements) do
    Enum.map(elements, fn element ->
      [x, y, z] = element.data
      %{x: x, y: y, z: z}
    end)
    |> Enum.reduce(fn element, acc ->
         %{
           acc
           | x: (acc.x + element.x) / length(elements),
             y: acc.y + element.y,
             z: acc.z + element.z
         }
       end)
  end
end
