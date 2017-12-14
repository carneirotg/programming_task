defmodule ProgrammingTask.SensorMessageQueueTwo do
  use GenServer

  # server
  def init(queue) do
    schedule_write_to_elastic()
    {:ok, queue}
  end

  def handle_cast({:enqueue, value}, queue) do
    IO.puts("handle_cast TWO!")

    if is_nil(queue.first_time) do

      queue = %{
        queue
        | first_time: value.created_time,
          last_time: value.created_time,
          elements: [value | queue.elements]
      }

      {:noreply, queue}
    else
      queue = %{
        queue
        | last_time: value.created_time,
          elements: [value | queue.elements]
      }
    end
    IO.inspect(queue)
    {:noreply, queue}
  end

  def handle_info(:write, queue) do
    IO.puts("handle_info!")
    # IO.inspect(queue)

    if not is_nil(queue.first_time) do
      if DateTime.diff(queue.last_time, queue.first_time) >= 60 do
        window = []
        Enum.map(queue, fn(element) ->

        end)

      end
    end


    # schedule_write_to_elastic()
    {:noreply, queue}
  end

  ### Client API / Helper functions

  def start_link(state \\ []) do
    queue = %{first_time: nil, last_time: nil, elements: []}
    GenServer.start_link(__MODULE__, queue, name: __MODULE__)
  end

  defp schedule_write_to_elastic do
    # 5 seconds
    Process.send_after(self(), :write, 5000)
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
