defmodule GenRetryTest do
  use ExSpec, async: true
  doctest GenRetry

  describe "task" do
    it "returns on success" do
      t = GenRetry.task(fn -> 22 end)
      assert(22 == Task.await(t))
    end
  end

end

