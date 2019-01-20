defmodule Servy.Tracker do
  def get_location(wildthing) do
    :timer.sleep(500)

    locations = %{
      "roscoe"  => %{ lat: "44.4563 N", lng: "110.5885 W" },
      "smokey"  => %{ lat: "45.4563 N", lng: "111.5885 W" },
      "brutus"  => %{ lat: "46.4563 N", lng: "112.5885 W" },
      "bigfoot" => %{ lat: "47.4563 N", lng: "113.5885 W" },
    }

    Map.get(locations, wildthing)
  end
end
