defmodule Core.MessageTest do
  use Core.ModelCase

  alias Core.Message

  @valid_attrs %{contact_first_name: "some content", contact_last_name: "some content", contact_phone: "some content", conversation_id: 42, message_body: "some content", message_direction: "some content", message_id: 42, sender_first_name: "some content", sender_last_name: "some content", sender_phone: "some content", timestamp: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Message.changeset(%Message{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Message.changeset(%Message{}, @invalid_attrs)
    refute changeset.valid?
  end
end
