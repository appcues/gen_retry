defmodule GenRetryTest do
  use ExSpec, async: true
  doctest GenRetry

  context "Task.async" do
    it "returns on success" do
      t = GenRetry.Task.async(fn -> 22 end)
      assert(22 == Task.await(t))
    end
  end

  context "GenRetry.retry_link" do
    it "uses on_success" do
      pid = self()

      GenRetry.retry_link(
        fn -> 23 end,
        on_success: fn succ -> send(pid, succ) end,
        on_failure: fn fail -> send(pid, {:failure, fail}) end
      )

      assert_receive {23, %{}}
      refute_receive {:failure, _}
    end

    it "uses on_failure" do
      pid = self()

      GenRetry.retry_link(
        fn -> raise "oops" end,
        retries: 0,
        on_success: fn succ -> send(pid, {:success, succ}) end,
        on_failure: fn fail -> send(pid, {:failure, fail}) end
      )

      assert_receive({:failure, {_exception, _stacktrace, %{}}})
      refute_receive({:success, _})
    end
  end
end
