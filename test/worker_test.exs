defmodule GenRetry.WorkerTest do
  use ExSpec, async: true

  import Mock

  context "logger" do
    it "logs errors as they happen before retrying" do
      with_mock GenRetry.TestLogger, log: fn _ -> nil end do
        try do
          task = GenRetry.Task.async(fn -> raise "An Error!" end)
          :erlang.unlink(task.pid)

          Task.await(task)
        catch
          :exit, _ -> "squelch error"
        end

        assert_called(
          GenRetry.TestLogger.log("%RuntimeError{message: \"An Error!\"}")
        )
      end
    end
  end
end
