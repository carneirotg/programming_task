defmodule ProgrammingTask.SensorMessageControllerTest do
  use ProgrammingTask.ConnCase

  alias Poison

  test "GET /api/health" do
    conn = get(build_conn(), "/api/health")
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "Sends single measurement AGT_0001" do
    payload = %{
      "createdTime" => "2017-10-06T19:30:52.942000Z",
      "data" => [-1, 0.7, 0.3],
      "dataType" => "accelerometer",
      "dataUnit" => "m/s^2",
      "sensorId" => "AGT0001"
    }

    body = Poison.encode!(payload)

    conn =
      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/api/measurements", body)

    assert conn.status == 201
    assert conn.resp_body == "OK"
  end

  test "Sends single measurement AGT_0002" do
    payload = %{
      "createdTime" => "2017-10-06T19:30:52.942000Z",
      "data" => [-1, 0.7, 0.3],
      "dataType" => "accelerometer",
      "dataUnit" => "m/s^2",
      "sensorId" => "AGT0002"
    }

    body = Poison.encode!(payload)

    conn =
      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/api/measurements", body)

    assert conn.status == 201
    assert conn.resp_body == "OK"
  end

  test "Sends batch measurements" do
    payload = [%{
      "createdTime" => "2017-10-06T19:30:52.942000Z",
      "data" => [-1, 0.7, 0.3],
      "dataType" => "accelerometer",
      "dataUnit" => "m/s^2",
      "sensorId" => "AGT0002"
    },
    %{
      "createdTime" => "2017-10-06T19:30:52.942000Z",
      "data" => [-1, 0.7, 0.3],
      "dataType" => "accelerometer",
      "dataUnit" => "m/s^2",
      "sensorId" => "AGT0001"
    }]

    body = Poison.encode!(payload)

    conn =
      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/api/measurements", body)

    assert conn.status == 201
    assert conn.resp_body == "OK"
  end

  test "Sends invalid sensorId" do
    payload = %{
      "createdTime" => "2017-10-06T19:30:52.942000Z",
      "data" => [-1, 0.7, 0.3],
      "dataType" => "accelerometer",
      "dataUnit" => "m/s^2",
      "sensorId" => "AGT0003"
    }

    body = Poison.encode!(payload)

    conn =
      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/api/measurements", body)

    assert conn.status == 400
    assert conn.resp_body == "The sensorId sent does not exist."
  end
end
