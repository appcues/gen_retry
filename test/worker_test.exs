defmodule GenRetry.WorkerTest do
  # Mocks cannot be done asynchronously without leaking to other test cases.
  use ExSpec, async: false

  import Mock

  context "logger" do
    it "logs errors as they happen before retrying" do
      test_log = fn message ->
        assert message =~ "(RuntimeError) An Error!"
      end

      with_mock GenRetry.TestLogger, log: test_log do
        try do
          task =
            GenRetry.Task.async(fn ->
              raise("An Error!")
            end)

          :timer.sleep(100)

          GenRetry.Task.await(task)
        rescue
          _ -> "squelch error"
        end

        assert_called(GenRetry.TestLogger.log(:_))
      end
    end
  end
end
