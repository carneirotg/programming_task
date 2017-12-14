defmodule ProgrammingTask.SensorMessageController do
  use ProgrammingTask.Web, :controller

  alias ProgrammingTask.SensorMessageQueueOne
  alias ProgrammingTask.SensorMessageQueueTwo
  alias ProgrammingTask.Utils

  def create(
        conn,
        params = %{"sensorId" => "AGT0002"}
      ) do
    sensor_message = deserialize_sensor_message(params)

    if is_map(sensor_message) do
      SensorMessageQueueTwo.enqueue(sensor_message)

      conn
      |> put_status(201)
      |> text("OK")
    else
      conn
      |> put_status(400)
      |> text(elem(sensor_message, 1))
    end
  end

  def create(
        conn,
        params = %{"sensorId" => "AGT0001"}
      ) do
    sensor_message = deserialize_sensor_message(params)

    if is_map(sensor_message) do
      SensorMessageQueueOne.enqueue(sensor_message)

      conn
      |> put_status(201)
      |> text("OK")
    else
      conn
      |> put_status(400)
      |> text(elem(sensor_message, 1))
    end
  end

  def create(conn, params = %{"_json" => elements}) do
    if not is_nil(params["_json"]) do
      filter_list(params["_json"])

      conn
      |> put_status(201)
      |> text("OK")
    else
      conn
      |> put_status(400)
      |> text("Empty list")
    end
  end

  # Helper functions
  def filter_list(params) do
    Enum.map(params, fn element ->
      IO.inspect(element["sensorId"])

      case element["sensorId"] do
        "AGT0001" ->
          element
          |> deserialize_sensor_message
          |> SensorMessageQueueOne.enqueue()

        "AGT0002" ->
          element
          |> deserialize_sensor_message
          |> SensorMessageQueueTwo.enqueue()
      end
    end)
  end

  def deserialize_sensor_message(element) do
    created_time = Utils.check_date_time(Map.get(element, "createdTime"))

    if is_tuple(created_time) do
      created_time
    else
      data =
        case Map.get(element, "dataUnit") do
          "g-force" ->
            Utils.convert_data_unit(Map.get(element, "data"))

          "m/s^2" ->
            Map.get(element, "data")
        end

      %{
        created_time: created_time,
        data: data,
        data_type: Map.get(element, "dataType"),
        data_unit: "m/s^2",
        sensor_id: Map.get(element, "sensorId")
      }
    end
  end
end
