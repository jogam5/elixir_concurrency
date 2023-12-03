defmodule Crawler do
  """
  Crawler module

  Steps:
  1. Read the file with the urls
  2. Loop through the urls 
  3. Access each url with a GET request 
  4. Download the image
  5. Save the image with a given file in a given path
  """
  def retrieve_lines_in_file(file_path) do
    case File.read(file_path) do
      {:ok, content} -> 
        content 
        |> String.split("\n")
        |> Enum.reject(&String.trim(&1) == "")
        {:ok, lines} -> Enum.each(lines, &IO.puts/1)
      {:error, reason} -> raise "Error reading file: #{reason}"
    end
  end

  def download_single_image(url, filename) do
    headers = [
      {"User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1815.114 Safari/537.36"}]

    timeout = 5_000  # Set your desired timeout in milliseconds

    case HTTPoison.get(url, headers, timeout: timeout, recv_timeout: timeout) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        File.write!(filename, body)
        IO.puts "Image downloaded #{filename}"
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.puts "Unexpected response: #{status_code} in url: #{url}"
        {:error, :unexpected_response}
      {:error, %HTTPoison.Error{reason: reason}} ->
        case reason do
          :timeout ->
            IO.puts "Timeout downloading image: #{url}"
            {:error, :timeout}
          _ ->
            IO.puts "Error downloading image: #{reason}"
            {:error, reason}
        end
    end
  end

  def download_images(file_path, output_path) do
    urls = retrieve_lines_in_file(file_path)

    Enum.with_index(urls)
    |> Enum.each(fn {url, i} ->
      img_name = "img_#{i+1}.jpg"
      filename = Path.join(output_path, img_name)
      download_single_image(url, filename)
    end)
  end

  defp measure_execution_time(fun) do
    {:ok, datetime} = Calendar.DateTime.now("America/Toronto")
    IO.puts "Start time: #{datetime}"

    start_time_monotonic = System.monotonic_time()
    fun.()
    end_time_monotonic = System.monotonic_time()
    elapsed_time= end_time_monotonic - start_time_monotonic

    {:ok, datetime} = Calendar.DateTime.now("America/Toronto")
    IO.puts "End time: #{datetime}"
    IO.puts "Execution time: #{System.convert_time_unit(elapsed_time, :native, :second)} s"
  end

  def run(file_path, output_path) do
    measure_execution_time(fn -> download_images(file_path, output_path) end)
  end

end
