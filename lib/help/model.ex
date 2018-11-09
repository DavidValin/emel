defmodule Help.Model do
  @moduledoc false
  import Integer, only: [is_odd: 1]

  def parse(s) do
    {parsed, ""} = s
                   |> String.trim()
                   |> Float.parse()
    parsed
  end

  def categorizer(categories_separated_by_thresholds) do
    thresholds = categories_separated_by_thresholds
                 |> Enum.with_index()
                 |> Enum.filter(fn {_, i} -> is_odd(i) end)
                 |> Enum.map(fn {v, _} -> v end)
    if Enum.any?(thresholds, fn x -> !is_number(x) end) || thresholds != Enum.sort(thresholds) do
      raise "Categories are not separated by valid thresholds"
    end
    fn value -> categories_separated_by_thresholds
                |> Enum.take_while(fn x -> !is_number(x) || value > x end)
                |> List.last()
    end
  end

  def normalize(dataset, keys) do
    f_by_key = keys
               |> Enum.map(
                    fn k -> vals = Enum.map(dataset, fn row -> row[k] end)
                            min_val = Enum.min(vals)
                            max_val = Enum.max(vals)
                            {k, fn v -> (v - min_val) / (max_val - min_val) end}
                    end
                  )
               |> Map.new()
    for row <- dataset do
      row
      |> Enum.map(
           fn {k, v} -> case Enum.member?(keys, k) do
                          true -> {k, f_by_key[k].(v)}
                          false -> {k, v}
                        end
           end
         )
      |> Map.new()
    end
  end

  # model

  def training_and_test_sets(dataset, ratio) do
    l = length(dataset)
    n = trunc(l * ratio)
    dataset
    |> Enum.shuffle()
    |> Enum.split(n)
  end

end
