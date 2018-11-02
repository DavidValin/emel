defmodule Ml.KMeans do
  @moduledoc ~S"""
  Aims to partition n _observations_ into k _clusters_
  in which each _observation_ belongs to the _cluster_ with the nearest _mean_.

  """
  alias Help.Utils
  alias Math.Geometry

  defp point_groups(points, centroids) do
    points
    |> Enum.group_by(fn p -> Geometry.nearest_neighbor(p, centroids) end)
    |> Enum.map(fn {k, v} -> %Utils.Pair{first: k, second: v} end)
    |> Enum.sort_by(&(&1.first))
  end

  defp iterate(clusters) do
    groups = Enum.map(clusters, &(&1.second))
    points = Enum.concat(groups)
    old_centroids = Enum.map(clusters, &(&1.first))
    new_centroids = groups
                    |> Enum.map(&Geometry.centroid/1)
                    |> Enum.sort()
    case new_centroids do
      ^old_centroids ->
        clusters
      _ ->
        points
        |> point_groups(new_centroids)
        |> iterate()
    end
  end

  @doc ~S"""
  `Points` partitioned into `k` _clusters_ in which each _point_ belongs to the _cluster_ with the nearest _mean_.

  ## Examples

      iex> Ml.KMeans.clusters([[1.0, 1.0],
      ...>                     [2.0, 1.0],
      ...>                     [4.0, 3.0],
      ...>                     [5.0, 4.0]],
      ...>                     2)
      [[[1.0, 1.0], [2.0, 1.0]],
       [[4.0, 3.0], [5.0, 4.0]]]

      iex> Ml.KMeans.clusters([[0.0, 0.0],
      ...>                     [4.0, 4.0],
      ...>                     [9.0, 9.0],
      ...>                     [4.3, 4.3],
      ...>                     [9.9, 9.9],
      ...>                     [4.4, 4.4],
      ...>                     [0.1, 0.1]],
      ...>                     3)
      [[[0.0, 0.0], [0.1, 0.1]],
       [[4.0, 4.0], [4.3, 4.3], [4.4, 4.4]],
       [[9.0, 9.0], [9.9, 9.9]]]

  """
  def clusters(_, k) when k <= 0, do: raise "K should be positive"
  def clusters(points, k) when k > length(points), do: raise "K should be less or equal to the number of points"
  def clusters(points, k) do
    centroids = points
                |> Enum.shuffle()
                |> Enum.uniq()
                |> Enum.take(k)
    points
    |> point_groups(centroids)
    |> iterate()
    |> Enum.map(&(&1.second))
  end

  @doc ~S"""
  Returns the function that classifies an item by identifying the _cluster_ it belongs to.

  ## Examples

      iex> f = Ml.KMeans.classifier([[1.0, 1.0],
      ...>                           [2.0, 1.0],
      ...>                           [4.0, 3.0],
      ...>                           [5.0, 4.0]],
      ...>                           2)
      ...> f.([1.5, 1.5])
      "0"

  """
  def classifier(points, num_of_classes) do
    centroids = points
                |> clusters(num_of_classes)
                |> Enum.map(&Geometry.centroid/1)
    class_by_centroid = centroids
    |> Enum.with_index()
    |> Enum.map(fn {cntr, i} -> {cntr, Integer.to_string(i)} end)
    |> Map.new()
    fn item ->
      selected_centroid = Geometry.nearest_neighbor(item, centroids)
      class_by_centroid[selected_centroid]
    end
  end

end
