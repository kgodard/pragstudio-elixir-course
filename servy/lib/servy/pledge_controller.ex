defmodule Servy.PledgeController do
  import Servy.View, only: [render: 3]

  alias Servy.PledgeServer

  def new(conv) do
    render(conv, "new_pledge.eex", [])
  end

  def create(conv, %{"Name" => name, "Amount" => amount}) do
    # sends pledge to external service and caches it
    PledgeServer.create_pledge(name, String.to_integer(amount))

    %{ conv | status: 201, resp_body: "#{name} pledged #{amount}!\n" }
  end

  def create(conv, %{"name" => name, "amount" => amount}) do
    # sends pledge to external service and caches it
    PledgeServer.create_pledge(name, String.to_integer(amount))

    %{ conv | status: 201, resp_body: "#{name} pledged #{amount}!\n" }
  end

  def index(conv) do
    # Gets the recent pledges from the cache
    pledges = PledgeServer.recent_pledges()

    render(conv, "recent_pledges.eex", pledges: pledges)
  end

end
