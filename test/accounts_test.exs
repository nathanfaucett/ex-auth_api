defmodule AuthApi.AccountsTest do
  use AuthApi.DataCase

  alias AuthApi.Accounts
  alias AuthApi.Accounts.User
  alias AuthApi.Accounts.Session
  alias AuthApi.Accounts.Application

  @create_user_attrs %{confirmed: true, email: "some@email.com", password: "some password"}
  @update_user_attrs %{email: "some_updated@email.com", password: "some updated password"}
  @invalid_user_attrs %{email: "", password: ""}

  @create_application_attrs %{name: "some name"}
  @update_application_attrs %{name: "some updated name"}
  @invalid_application_attrs %{name: nil}


  def fixture(:user, attrs) do
    {:ok, user} = Accounts.create(attrs)
    user
  end

  def fixture(:application, attrs) do
    user = fixture(:user, @create_user_attrs)
    {:ok, application} = Accounts.create_application(
      Map.put(attrs, :owner_id, user.id)
    )
    application
  end


  test "create/1 with valid data creates a user" do
    assert {:ok, %User{}} = Accounts.create(@create_user_attrs)
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Accounts.create(@invalid_user_attrs)
  end

  test "update/2 with valid data updates the user" do
    user = fixture(:user, @create_user_attrs)
    assert {:ok, user} = Accounts.update(user, @update_user_attrs)
    assert %User{} = user
  end

  test "update/2 with invalid data returns error changeset" do
    user = fixture(:user, @create_user_attrs)
    assert {:error, %Ecto.Changeset{}} = Accounts.update(user, @invalid_user_attrs)
    assert user == Accounts.get!(user.id)
  end

  test "delete_user/1 deletes the user" do
    user = fixture(:user, @create_user_attrs)
    assert {:ok, %User{}} = Accounts.delete(user)
    assert_raise Ecto.NoResultsError, fn -> Accounts.get!(user.id) end
  end


  test "create_session/1 with valid data creates a session for a user" do
    _user = fixture(:user, @create_user_attrs)
    assert {:ok, %Session{}} = Accounts.create_session(@create_user_attrs)
  end

  test "get_user_by_session/1 with valid session returns the user" do
    _user = fixture(:user, @create_user_attrs)
    {:ok, session} = Accounts.create_session(@create_user_attrs)
    assert %User{} = Accounts.get_user_by_session(session)
  end

  test "delete_session/1 with valid session deletes session" do
    _user = fixture(:user, @create_user_attrs)
    {:ok, session} = Accounts.create_session(@create_user_attrs)
    assert {:ok, %Session{}} = Accounts.delete_session(session)
  end


  test "list_applications/1 returns all accounts" do
    application = fixture(:application, @create_application_attrs)
    assert Accounts.list_applications(application.owner_id) == []
  end

  test "get_application! returns the application with given id" do
    application = fixture(:application, @create_application_attrs)
    assert Accounts.get_application!(application.id) == application
  end

  test "create_application/1 with valid data creates a application" do
    user = fixture(:user, @create_user_attrs)
    assert {:ok, %Application{} = application} = Accounts.create_application(Map.put(
      @create_application_attrs, :owner_id, user.id
    ))
    assert application.name == "some name"
  end

  test "create_application/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Accounts.create_application(@invalid_application_attrs)
  end

  test "update_application/2 with valid data updates the application" do
    application = fixture(:application, @create_application_attrs)
    assert {:ok, application} = Accounts.update_application(application, @update_application_attrs)
    assert %Application{} = application
    assert application.name == "some updated name"
  end

  test "update_application/2 with invalid data returns error changeset" do
    application = fixture(:application, @create_application_attrs)
    assert {:error, %Ecto.Changeset{}} = Accounts.update_application(application, @invalid_application_attrs)
    assert application == Accounts.get_application!(application.id)
  end

  test "delete_application/1 deletes the application" do
    application = fixture(:application, @create_application_attrs)
    assert {:ok, %Application{}} = Accounts.delete_application(application)
    assert_raise Ecto.NoResultsError, fn -> Accounts.get_application!(application.id) end
  end

  test "application_changeset/2 returns a application changeset" do
    application = fixture(:application, @create_application_attrs)
    assert %Ecto.Changeset{} = Accounts.application_changeset(application, %{})
  end
end
