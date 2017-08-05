defmodule Core.RelayTaskTest do
  use Core.ModelCase

  alias Core.RelayTask

  @valid_attrs %{end_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, pid: "some content", start_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, status: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = RelayTask.changeset(%RelayTask{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = RelayTask.changeset(%RelayTask{}, @invalid_attrs)
    refute changeset.valid?
  end
end
