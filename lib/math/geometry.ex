defmodule Math.Geometry do
  @moduledoc false

  @doc ~S"""
  The sum of the products of the corresponding entries of `x` and `y`.

  ## Examples

      iex> Math.Geometry.dot_product([-4.0, -9.0], [-1.0, 2.0])
      -14.0

      iex> Math.Geometry.dot_product([1.0, 2.0, 3.0], [4.0, -5.0, 6.0])
      12.0

  """
  def dot_product(x, y) do
    x
    |> Enum.zip(y)
    |> Enum.map(fn {a, b} -> a * b end)
    |> Enum.sum()
  end

  @doc ~S"""
  The ordinary straight-line distance between two points in _Euclidean space_.

  ## Examples

      iex> Math.Geometry.euclidean_distance([2.0, -1.0], [-2.0, 2.0])
      5.0

      iex> Math.Geometry.euclidean_distance([0.0, 3.0, 4.0, 5.0], [7.0, 6.0, 3.0, -1.0])
      9.746794344808963

  """
  def euclidean_distance(x, y) do
    x
    |> Enum.zip(y)
    |> Enum.map(fn {a, b} -> (b - a) * (b - a) end)
    |> Enum.sum()
    |> :math.sqrt()
  end


  @doc ~S"""
  The neighbor that is closest to the given `point`.

  ## Examples

      iex> Math.Geometry.nearest_neighbor([0.9, 0.0], [[0.0, 0.0], [0.0, 0.1], [1.0, 0.0], [1.0, 1.0]])
      [1.0, 0.0]

  """
  def nearest_neighbor(point, neighbors, distance \\ &euclidean_distance/2) do
    Enum.min_by(neighbors, fn n -> distance.(n, point) end)
  end

end
