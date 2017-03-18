defmodule AuthApi.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """
  import Comeonin.Bcrypt
  import Ecto.{Query, Changeset}, warn: false

  use Phoenix.Controller

  alias AuthApi.Repo

  alias AuthApi.Accounts.User
  alias AuthApi.Accounts.Session
  alias AuthApi.Accounts.Application


  def user_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :active, :confirmed, :confirmation_token])
    |> validate_required([:email, :active, :confirmed])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  def user_registration_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :confirmed])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> put_change(:encrypted_password,
        hashpwsalt(Map.get(attrs, :password, Map.get(attrs, "password", nil))))
    |> put_change(:confirmation_token, SecureRandom.urlsafe_base64())
  end


  def session_changeset(%Session{} = session, attrs) do
    session
    |> cast(attrs, [:user_id])
    |> foreign_key_constraint(:user_id)
    |> validate_required([:user_id])
  end

  def session_registration_changeset(%Session{} = session, attrs) do
    session
    |> session_changeset(attrs)
    |> put_change(:token, SecureRandom.urlsafe_base64())
    |> unique_constraint(:token)
  end


  def application_changeset(%Application{} = application, attrs) do
    application
    |> cast(attrs, [:name, :owner_id])
    |> foreign_key_constraint(:owner_id)
    |> validate_required([:name, :owner_id])
  end

  defp application_registration_changeset(%Application{} = application, attrs) do
    application
    |> application_changeset(attrs)
    |> put_change(:token, SecureRandom.urlsafe_base64())
  end


  def create(attrs \\ %{}) do
    %User{}
    |> user_registration_changeset(attrs)
    |> Repo.insert()
  end

  def update(%User{} = user, attrs) do
    user
    |> user_changeset(attrs)
    |> Repo.update()
  end

  def new_confirmation_token(%User{} = user) do
    AuthApi.Accounts.update(user, %{
      confirmation_token: SecureRandom.urlsafe_base64()
    })
  end

  def confirm(%User{} = user, token) do
    if !user.confirmed && user.confirmation_token == token do
      AuthApi.Accounts.update(user, %{
        confirmed: true,
        confirmation_token: nil
      })
    else
      {:unauthorized}
    end
  end

  def get(id), do: Repo.get(User, id)
  def get!(id), do: Repo.get!(User, id)

  def delete(%User{} = user), do: Repo.delete(user)
  def delete!(%User{} = user), do: Repo.delete!(user)


  def create_session(attrs \\ %{}) do
    email = Map.get(attrs, :email, Map.get(attrs, "email", nil))
    password = Map.get(attrs, :password, Map.get(attrs, "password", nil))
    user = Repo.get_by(User, email: email)

    if user != nil && checkpw(password, user.encrypted_password) do
      session_registration_changeset(%Session{}, %{user_id: user.id})
      |> Repo.insert()
    else
      dummy_checkpw()
      {:unauthorized}
    end
  end

  def get_user_by_session(session) do
    Repo.get_by(User, id: session.user_id)
  end

  def get_session(id), do: Repo.get(Session, id)
  def get_session!(id), do: Repo.get!(Session, id)

  def delete_session(session), do: Repo.delete(session)
  def delete_session!(session), do: Repo.delete!(session)

  def get_session_from_conn(conn) do
    case get_req_header(conn, "x-auth-api-user-token") do
      [token] ->
          Repo.get_by(Session, token: token)
      _ ->
        nil
    end
  end


  def list_applications(owner_id) do
    query = from a in Application,
      where: a.owner_id > ^owner_id
    Repo.all(query)
  end

  def create_application(attrs \\ %{}) do
    %Application{}
    |> application_registration_changeset(attrs)
    |> Repo.insert()
  end

  def update_application(%Application{} = application, attrs) do
    application
    |> application_changeset(attrs)
    |> Repo.update()
  end

  def get_application(id), do: Repo.get(Application, id)
  def get_application!(id), do: Repo.get!(Application, id)

  def delete_application(%Application{} = application), do: Repo.delete(application)
  def delete_application!(%Application{} = application), do: Repo.delete!(application)

  def get_application_from_conn(conn) do
    case get_req_header(conn, "x-auth-api-application-token") do
      [token] ->
          Repo.get_by(Application, token: token)
      _ ->
        nil
    end
  end
end
