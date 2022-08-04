defmodule UnLibTest do
  use ExUnit.Case
  doctest UnLib

  test "greets the world" do
    assert UnLib.hello() == :world
  end
end
