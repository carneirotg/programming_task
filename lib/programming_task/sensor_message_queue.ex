defmodule ProgrammingTask.SensorMessageQueue do
  use GenServer
  use Timex

  alias ProgrammingTask.ElasticHandler

  @scheduled_time 5000

  # server
  def init(queue) do
    schedule_write_to_elastic()
    {:ok, queue}
  end

  def handle_cast({:enqueue, value}, queue) do
    case queue.begin_time do
      nil ->
        queue =
          queue
          |> put_in([:sensor_id], value.sensor_id)
          |> put_in([:begin_time], value.created_time)
          |> put_in([:elements], [value | queue.elements])

      _ ->
        queue =
          queue
          |> put_in([:elements], [value | queue.elements])
    end

    {:noreply, queue}
  end

  def handle_info(:write, queue) do
    if not is_nil(queue.begin_time) do
      end_time = Timex.shift(queue.begin_time, minutes: 1)

      window =
        Enum.filter(queue.elements, fn value ->
          Timex.between?(value.created_time, queue.begin_time, end_time, inclusive: true)
        end)

      if length(window) > 1 do
        body = %{
          start: DateTime.to_iso8601(queue.begin_time, :extended),
          end: DateTime.to_iso8601(end_time, :extended),
          sensorId: queue.sensor_id,
          avg: average(window)
        }

        post_to_elastic(body)
      end

      queue =
        queue
        |> put_in([:begin_time], Timex.shift(queue.begin_time, seconds: 5))
    end

    schedule_write_to_elastic()
    {:noreply, queue}
  end

  def post_to_elastic(params) do
    ElasticHandler.put(ELASTIC, params)
  end

  ### Client API / Helper functions

  def start_link(state \\ []) do
    queue = %{begin_time: nil, elements: [], sensor_id: nil}
    GenServer.start_link(__MODULE__, queue, name: state)
  end

  defp schedule_write_to_elastic do
    # 5 seconds
    Process.send_after(self(), :write, @scheduled_time)
  end

  def enqueue(value, name) do
    GenServer.cast(name, {:enqueue, value})
  end

  defp average(elements) do
    Enum.map(elements, fn element ->
      [x, y, z] = element.data
      %{x: x, y: y, z: z}
    end)
    |> Enum.reduce(fn element, acc ->
         %{
           acc
           | x: (acc.x + element.x) / length(elements),
             y: (acc.y + element.y) / length(elements),
             z: (acc.z + element.z) / length(elements)
         }
       end)
  end
end
