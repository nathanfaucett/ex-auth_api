defmodule AuthApi.Web.SessionControllerTest do
  use AuthApi.Web.ConnCase

  alias AuthApi.Accounts

  @create_user_attrs %{email: "some@email.com", password: "some password"}
  @invalid_user_attrs %{email: "some@email.com", password: "invalid"}


  def fixture(:user) do
    user_attrs = @create_user_attrs
    {:ok, user} = Accounts.create(user_attrs)
    user
  end
  def fixture(:session) do
    user_attrs = @create_user_attrs
    _user = fixture(:user)
    {:ok, session} = Accounts.create_session(%{
      email: user_attrs.email, password: user_attrs.password})
    session
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "creates session and renders session when data is valid", %{conn: conn} do
    user_attrs = @create_user_attrs
    _user = fixture(:user)

    conn = post conn, session_path(conn, :create), session: user_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, session_path(conn, :show, id)
    assert json_response(conn, 200)["data"]["id"] == id
  end

  test "does not create session and renders errors when data is invalid", %{conn: conn} do
    user_attrs = @invalid_user_attrs
    _user = fixture(:user)

    conn = post conn, session_path(conn, :create), session: user_attrs
    assert json_response(conn, 401)["errors"] != %{}
  end

  test "deletes chosen session", %{conn: conn} do
    session = fixture(:session)
    conn = delete conn, session_path(conn, :delete, session)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, session_path(conn, :show, session)
    end
  end
end
