defmodule AuthApi.Web.UserControllerTest do
  use AuthApi.Web.ConnCase

  alias AuthApi.Repo
  alias AuthApi.Accounts
  alias AuthApi.Accounts.User
  alias AuthApi.Accounts.Application

  @create_attrs %{email: "some@email.com", password: "some password"}
  @update_attrs %{email: "some_updated@email.com", password: "some updated password"}
  @invalid_attrs %{email: "", password: ""}

  def fixture(:user) do
    {:ok, user} = Accounts.create(@create_attrs)
    user
  end
  def fixture(:session, user_attrs) do
    {:ok, session} = Accounts.create_session(%{
      email: user_attrs.email, password: user_attrs.password})
    session
  end

  def put_session_token(conn, user_attrs) do
    session = fixture(:session, user_attrs)
    put_req_header(conn, "x-auth-api-user-token", session.token)
  end

  setup %{conn: conn} do
    application = Repo.get_by(Application, name: "Auth Api")
    {:ok, conn: conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("x-auth-api-application-token", application.token)}
  end

  test "creates user and renders user when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @create_attrs
    assert %{"id" => _id,
      "active" => true,
      "confirmed" => false,
      "email" => "some@email.com"} = json_response(conn, 201)["data"]
  end

  test "does not create user and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen user and renders user when data is valid", %{conn: conn} do
    %User{id: id} = user = fixture(:user)
    conn = put_session_token(conn, @create_attrs)

    conn = put conn, user_path(conn, :update, user), user: @update_attrs
    assert  %{
      "id" => ^id,
      "active" => true,
      "confirmed" => false,
      "email" => "some_updated@email.com"} = json_response(conn, 200)["data"]
  end

  test "does not update chosen user and renders errors when data is invalid", %{conn: conn} do
    user = fixture(:user)
    conn = put_session_token(conn, @create_attrs)
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen user", %{conn: conn} do
    user = fixture(:user)
    conn = put_session_token(conn, @create_attrs)
    conn = delete conn, user_path(conn, :delete, user)
    assert response(conn, 204)
  end

  test "should confirm user based on token", %{conn: conn} do
    user = fixture(:user)
    conn = put_session_token(conn, @create_attrs)

    conn = post conn, user_path(conn, :confirm, user.confirmation_token), %{}
    assert json_response(conn, 204)

    confirmed_user = Accounts.get!(user.id)
    assert confirmed_user.confirmed == true
    assert confirmed_user.confirmation_token == nil
  end

  test "should not confirm user based on invalid token", %{conn: conn} do
    user = fixture(:user)
    conn = put_session_token(conn, @create_attrs)

    conn = post conn, user_path(conn, :confirm, "invalid token"), %{}
    assert json_response(conn, 401)

    confirmed_user = Accounts.get!(user.id)
    assert confirmed_user.confirmed == false
  end

  test "resends confirmation token email", %{conn: conn} do
    _user = fixture(:user)
    conn = put_session_token(conn, @create_attrs)

    conn = post conn, user_path(conn, :resend_confirmation_token), %{}
    assert json_response(conn, 204)
  end
end
