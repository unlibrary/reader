defmodule AccountsTest do
  use ExUnit.Case, async: true
  use UnLib.RepoCase

  import UnLib.Fixtures

  alias UnLib.Account
  alias UnLib.Accounts

  test "create/3 returns an account struct and downcases username" do
    {:ok, %Account{username: "robin"}} = Accounts.create("Robin", valid_password())
  end

  @tag :broken
  test "create/3 validates username is unique" do
    {:error, %Account{username: "robin"}} = Accounts.create("Robin", valid_password())
    {:ok, %Ecto.Changeset{}} = Accounts.create("Robin", valid_password())
  end

  test "create/3 validates password" do
    invalid_password = "xxx"

    {:error,
     %Ecto.Changeset{
       errors: [
         password: {"should be at least %{count} character(s)", _}
       ]
     }} = Accounts.create("Robin", invalid_password)
  end

  test "create/3 has optional email param" do
    {:ok, %Account{email: nil}} = Accounts.create("User1", valid_password())

    {:ok, %Account{email: "robin@example.nl"}} =
      Accounts.create("User2", valid_password(), email: "robin@example.nl")

    {:error,
     %Ecto.Changeset{
       errors: [
         email: {"has invalid format", _}
       ]
     }} = Accounts.create("User3", valid_password(), email: "notanemailaddress")
  end

  @tag :broken
  test "create/3 validates email is unique" do
    email = "robin@example.nl"

    {:ok, %Account{username: "user1", email: ^email}} =
      Accounts.create("User1", valid_password(), email: email)

    {:error, %Ecto.Changeset{}} = Accounts.create("User2", valid_password(), email: email)
  end

  test "get/1 returns an account struct" do
    username = "robijntje"
    {:ok, %Account{id: user_id}} = Accounts.create(username, valid_password())

    {:ok, user} = Accounts.get(user_id)
    assert user.username == username
  end

  test "get_by_username/1 returns an account struct" do
    username = "robijntje"
    {:ok, %Account{id: user_id}} = Accounts.create(username, valid_password())

    {:ok, user} = Accounts.get_by_username(username)
    assert user.id == user_id
  end

  test "get_by_username/1 returns an error at unknown username" do
    username = "robin"
    other_username = "robijntje"

    {:ok, %Account{}} = Accounts.create(username, valid_password())

    {:error, error} = Accounts.get_by_username(other_username)
    assert error == :not_found
  end
end
