defmodule PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer

  setup_all do
    pid = PledgeServer.start()

    PledgeServer.create_pledge("larry", 10)
    PledgeServer.create_pledge("moe", 20)
    PledgeServer.create_pledge("curly", 30)
    PledgeServer.create_pledge("daisy", 40)
    PledgeServer.create_pledge("grace", 50)

    {:ok, pid: pid}
  end

  test "it caches the 3 most recent pledges" do
    recent = PledgeServer.recent_pledges()
             |> Enum.map(&elem(&1, 0))

    assert recent == ["grace", "daisy", "curly"]
  end

  test "it totals pledge amounts" do
    assert PledgeServer.total_pledged() == 120
  end
end
