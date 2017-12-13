defmodule ProgrammingTask.Utils do


  def check_date_time(date_time) do
    case DateTime.from_iso8601(date_time) do
      {:error, reason} ->
        {:error, "createdTime is invalid."}

      {:ok, parsed_datetime, 0} ->
        parsed_datetime
    end
  end

  def convert_data_unit(data_unit) do
    g_force_to_ms2 = 9.8
    data_unit
    |> Enum.map(fn(x) ->
      x * g_force_to_ms2
    end)
  end
end
