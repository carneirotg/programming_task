defmodule ProgrammingTask.SensorMessageControllerTest
  use ProgrammingTask.ConnCase

  test "index/2 responds with all Users"

  describe "create/2" do
    test "Creates, and responds with a newly created user if attributes are valid"
    test "Returns an error and does not create a user if attributes are invalid"
  end
  # test "Sends single measurement", %{conn: conn} do
  #   payload = %{
  #     "createdTime" => "2017-10-06T19:30:52.942000Z",
  #     "data" => [-1, 0.7, 0.3],
  #     "dataType" => "accelerometer",
  #     "dataUnit" => "m/s^2",
  #     "sensorId" => "AGT0002"
  #   }
  #   conn = post conn, "/api/measurements"
  #   assert html_response(conn, 201) = "OK"
  # end
end
gv
