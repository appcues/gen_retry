defmodule GenRetryTest do
  use ExSpec, async: true
  doctest GenRetry

  describe "Task.async" do
    it "returns on success" do
      t = GenRetry.Task.async(fn -> 22 end)
      assert(22 == Task.await(t))
    end

    it "bails on fails" do
      try do
        t = GenRetry.Task.async(fn -> raise "onoz" end, delay: 0)
        Task.await(t)
        assert(t == "the task should have raised an exception")
      rescue
        e ->
          assert("onoz" == Exception.message(e))
      end
    end
  end

end

