defmodule GenRetry.WorkerTest do
  use ExSpec, async: true

  import Mock

  context "logger" do
    it "logs errors as they happen before retrying" do
      with_mock GenRetry.Utils, log: fn _ -> nil end do
        task =
          GenRetry.Task.async(fn ->
            raise("An Error!")
          end)

        try do
          Task.await(task)
        rescue
          RuntimeError -> "squelch error"
        end

        assert_called(GenRetry.Utils.log())
      end
    end
  end
end
