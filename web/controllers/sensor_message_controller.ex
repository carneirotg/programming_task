defmodule ProgrammingTask.SensorMessageController do
  use ProgrammingTask.Web, :controller

  alias ProgrammingTask.SensorMessageQueue
  alias ProgrammingTask.Utils

  def create(
        conn,
        params = %{"sensorId" => "AGT0002"}
      ) do
    sensor_message = deserialize_sensor_message(params)

    if is_map(sensor_message) do
      SensorMessageQueue.enqueue(sensor_message, AGT_2)

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
      SensorMessageQueue.enqueue(sensor_message, AGT_1)

      conn
      |> put_status(201)
      |> text("OK")
    else
      conn
      |> put_status(400)
      |> text(elem(sensor_message, 1))
    end
  end

  def create(conn, %{"_json" => elements}) do
    if not is_nil(elements) do
      filter_list(elements)

      conn
      |> put_status(201)
      |> text("OK")
    else
      conn
      |> put_status(400)
      |> text("Empty list")
    end
  end

  #Endpoint to handle errors within the sensorIds
  def create(conn, params) do
    conn
    |> put_status(400)
    |> text("The sensorId sent does not exist.")
  end

  def health(conn, params) do
    conn
    |> put_status(200)
    |> text("OK")
  end

  # Helper functions
  def filter_list(params) do
    Enum.map(params, fn element ->
      IO.inspect(element["sensorId"])

      case element["sensorId"] do
        "AGT0001" ->
          element
          |> deserialize_sensor_message
          |> SensorMessageQueue.enqueue(AGT_1)

        "AGT0002" ->
          element
          |> deserialize_sensor_message
          |> SensorMessageQueue.enqueue(AGT_2)
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
