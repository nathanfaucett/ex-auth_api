defmodule AuthApi.Web.ApplicationControllerTest do
  use AuthApi.Web.ConnCase

  alias AuthApi.Repo
  alias AuthApi.Accounts
  alias AuthApi.Accounts.User
  alias AuthApi.Accounts.Session
  alias AuthApi.Accounts.Application

  @create_user_attrs %{email: "some@email.com", password: "some password"}

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}


  def fixture(:user) do
    {:ok, user} = Accounts.create(@create_user_attrs)
    user
  end
  def fixture(:application) do
    user = Repo.get_by(User, email: "nathanfaucett@gmail.com")
    {:ok, application} = Accounts.create_application(Map.put(
      @create_attrs, :owner_id, user.id
    ))
    application
  end

  def put_session_token(conn) do
    user = Repo.get_by(User, email: "nathanfaucett@gmail.com")
    session = Repo.insert!(
      Accounts.session_registration_changeset(%Session{}, %{user_id: user.id}))
    put_req_header(conn, "x-auth-api-user-token", session.token)
  end

  setup %{conn: conn} do
    application = Repo.get_by(Application, name: "Auth Api")
    {:ok, conn: conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("x-auth-api-application-token", application.token)}
  end

  test "creates application and renders application when data is valid", %{conn: conn} do
    conn = put_session_token(conn)
    conn = post conn, application_path(conn, :create), application: @create_attrs
    assert %{"id" => _id, "token" => _token} = json_response(conn, 201)["data"]
  end

  test "does not create application and renders errors when data is invalid", %{conn: conn} do
    conn = put_session_token(conn)
    conn = post conn, application_path(conn, :create), application: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen application and renders application when data is valid", %{conn: conn} do
    %Application{id: id, token: token} = application = fixture(:application)
    conn = put_session_token(conn)
    conn = put conn, application_path(conn, :update, application), application: @update_attrs
    assert %{"id" => ^id, "token" => ^token} = json_response(conn, 200)["data"]
  end

  test "does not update chosen application and renders errors when data is invalid", %{conn: conn} do
    application = fixture(:application)
    conn = put_session_token(conn)
    conn = put conn, application_path(conn, :update, application), application: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen application", %{conn: conn} do
    application = fixture(:application)
    conn = put_session_token(conn)
    conn = delete conn, application_path(conn, :delete, application)
    assert response(conn, 204)
  end
end
