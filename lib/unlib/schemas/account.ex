defmodule UnLib.Account do
  @moduledoc """
  Ecto Schema representing a user.
  """
  use UnLib.Schema
  import Ecto.Changeset

  alias UnLib.Auth
  alias TheBigUsernameBlacklist, as: Blacklist

  @derive {Jason.Encoder, except: [:hashed_password, :salt]}

  typed_schema "users" do
    field :username, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, source: :password
    field :salt, :string
    field :email, UnLib.Vault.Binary

    many_to_many :sources, UnLib.Source, join_through: "users_sources", on_replace: :delete

    timestamps()
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:username, :password, :email])
    |> maybe_validate_required([:username, :password], params)
    |> validate_email()
    |> downcase_username()
    |> validate_username()
    |> validate_password()
    |> hash_password()
    |> unique_constraint([:username, :email])
    |> unique_constraint([:email, :username])
  end

  defp maybe_validate_required(changeset, fields, opts) do
    if opts[:validate_required] do
      validate_required(changeset, fields)
    else
      changeset
    end
  end

  defp downcase_username(changeset) do
    update_change(changeset, :username, &String.downcase/1)
  end

  defp validate_username(changeset, _options \\ []) do
    changeset
    |> validate_format(:username, ~r/^[a-z0-9]*$/)
    |> validate_change(:username, &in_blacklist?/2)
    |> validate_unique(:username)
  end

  defp in_blacklist?(:username, username) do
    case Blacklist.valid?(username) do
      true -> []
      false -> [{:username, "is not allowed"}]
    end
  end

  defp validate_unique(changeset, key) do
    changeset
    |> unsafe_validate_unique(key, UnLib.Repo)
    |> unique_constraint(key)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_length(:password, min: 4)
    |> validate_length(:password, max: 72, count: :bytes)
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)

    if password && changeset.valid? do
      salt = Auth.get_salt()
      password_hash = Auth.hash_pass(password, salt)

      changeset
      |> put_change(:hashed_password, password_hash)
      |> put_change(:salt, salt)
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp validate_email(changeset) do
    changeset
    |> validate_format(:email, ~r/@/)
    |> validate_unique(:email)
  end
end
