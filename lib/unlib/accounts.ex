defmodule UnLib.Accounts do
  @moduledoc """
  Manages user accounts.
  """

  alias UnLib.{Repo, Account}
  alias UnLib.{Auth}

  @type create_opts :: [
          email: String.t()
        ]

  @spec create(String.t(), String.t(), create_opts()) ::
          {:ok, Account.t()} | {:error, any()}
  def create(username, password, opts \\ []) do
    email = Keyword.get(opts, :email)

    Account.changeset(%Account{}, %{
      username: username,
      password: password,
      email: email
    })
    |> Repo.insert()
    |> preload_sources()
  end

  defp preload_sources({:ok, user}) do
    {:ok, Repo.preload(user, :sources)}
  end

  defp preload_sources(error) do
    error
  end

  @spec login(String.t(), String.t()) ::
          {:ok, Account.t()} | {:error, :no_user_found | :invalid_password}
  def login(username, password) do
    case get_by_username(username) do
      {:ok, %Account{} = account} ->
        validate_password(account, password)

      _ ->
        {:error, :no_user_found}
    end
  end

  defp validate_password(account, password) do
    case password_valid?(account, password) do
      true -> {:ok, account}
      false -> {:error, :invalid_password}
    end
  end

  defp password_valid?(account, password) do
    hash_db = account.hashed_password
    salt = account.salt

    Auth.verify_pass(password, salt, hash_db)
  end

  @spec get(Ecto.UUID.t()) ::
          {:ok, Account.t()} | {:error, :not_found}
  def get(id) do
    Repo.get(Account, id)
    |> Repo.preload(:sources)
    |> handle_repo_response()
  end

  @spec get_by_username(String.t()) ::
          {:ok, Account.t()} | {:error, :not_found}
  def get_by_username(username) do
    Repo.get_by(Account, username: username)
    |> Repo.preload(:sources)
    |> handle_repo_response()
  end

  defp handle_repo_response(data) do
    case data do
      nil -> {:error, :not_found}
      account -> {:ok, account}
    end
  end

  @spec update(Account.t(), String.t() | atom(), any()) ::
          {:ok, Account.t()} | {:error, any()}
  def update(%Account{} = user, key, value) do
    Account.changeset(user, %{key => value})
    |> Repo.update()
  end
end
