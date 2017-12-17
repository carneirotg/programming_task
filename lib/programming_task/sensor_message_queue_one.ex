defmodule ProgrammingTask.SensorMessageQueueOne do
  use GenServer

  @scheduled_time 5000

  # server
  def init(queue) do
    schedule_write_to_elastic()
    {:ok, queue}
  end

  def handle_cast({:enqueue, value}, queue) do
    IO.puts("handle_cast!")

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

    # IO.inspect(queue)
    {:noreply, queue}
  end

  def handle_info(:write, queue) do
    IO.puts("handle_info!")
    # IO.inspect(queue)

    window = queue
    # IO.inspect(window.last.time)
    # IO.inspect(window.first.time)
    if not is_nil(window.first.time) do
      if DateTime.diff(window.last.time, window.first.time) >= 60 do
        IO.inspect("passou dos 60!")
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
    IO.inspect(params)
  end

  ### Client API / Helper functions

  def start_link(state \\ []) do
    queue = %{first: %{time: nil, index: nil}, last: %{time: nil, index: nil}, elements: [], count: 0, sensor_id: nil}
    GenServer.start_link(__MODULE__, queue, name: __MODULE__)
  end

  defp schedule_write_to_elastic do
    # 5 seconds
    Process.send_after(self(), :write, @scheduled_time)
  end

  def enqueue(value), do: GenServer.cast(__MODULE__, {:enqueue, value})

  #
  # def handle_cast({:push, payload}, queue) do
  #   IO.inspect("handle_cast begin")
  #   if is_nil(queue.first_tic) do
  #     IO.inspect("handle_cast -> nil")
  #     # Map.put(queue, :next_tic, item.created_time)
  #     {:noreply, %{queue | first_tic: item.created_time, elements: [item | queue.elements]}}
  #   else
  #     IO.inspect("handle_cast -> NOT nil")
  #     queue = %{queue | next_tic: item.created_time, elements: [item | queue.elements]}
  #     if DateTime.diff(queue.next_tic, queue.first_tic) >= 60 do
  #       IO.inspect("handle_cast -> more than 60")
  #       # calcular as medias
  #       average_sum = average(queue.elements)
  #       IO.inspect("average_sum:")
  #       IO.inspect(average_sum)
  #       # manda mensagem pro ElasticSearch
  #       # toElasticSearch
  #       #adicionar o elemento, first_tic = next_tic
  #     else
  #       IO.inspect("handle_cast -> NOT nil else")
  #       {:noreply, queue}
  #     end
  #   end
  # end

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
