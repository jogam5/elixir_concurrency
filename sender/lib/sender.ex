defmodule Sender do
  @moduledoc """
  Documentation for `Sender`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Sender.hello()
      :world

  """
  def hello do
    :world
  end

  def send_email("kok@world.com" = email), do:
    raise "Invalid email: #{email}"

  def send_email(email) do
    Process.sleep(3000)
    IO.puts("Sending email to #{email}")
    {:ok, "Email sent to #{email}"}
  end

  def notify_all(emails) do
    ### Without Task.Supervisor
    #emails
    #|> Task.async_stream(&send_email/1)
    
    ### With Task.Supervisor
    Sender.EmailTaskSupervisor
    |> Task.Supervisor.async_stream_nolink(emails, &send_email/1)
    |> Enum.to_list() 
  end
end
