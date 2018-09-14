defmodule GenRetryTest do
  use ExSpec, async: true
  doctest GenRetry

  context "Task.async" do
    it "returns on success" do
      t = GenRetry.Task.async(fn -> 22 end)
      assert(22 == Task.await(t))
    end
  end
end
