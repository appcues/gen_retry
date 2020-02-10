defmodule GenRetry.WorkerTest do
  use ExSpec, async: true

  import Mock

  context "logger" do
    it "logs errors as they happen before retrying" do
      with_mock GenRetry.TestLogger, log: fn _ -> nil end do
        try do
          task =
            GenRetry.Task.async(fn ->
              raise("An Error!")
            end)

          :timer.sleep(100)

          GenRetry.Task.await(task)
        rescue
          _e in UndefinedFunctionError -> "squelch error"
        end

        assert_called(
          GenRetry.TestLogger.log("%RuntimeError{message: \"An Error!\"}")
        )
      end
    end
  end
end
