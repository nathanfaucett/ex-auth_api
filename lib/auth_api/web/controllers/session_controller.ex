defmodule AuthApi.Web.SessionController do
  use AuthApi.Web, :controller

  alias AuthApi.Accounts
  alias AuthApi.Accounts.Session

  action_fallback AuthApi.Web.FallbackController


  def create(conn, %{"session" => session_params}) do
    with {:ok, %Session{} = session} <- Accounts.create_session(session_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", session_path(conn, :show, session))
      |> render("show.json", session: session)
    end
  end

  def show(conn, %{"id" => id}) do
    session = Accounts.get_session!(id)
    render(conn, "show.json", session: session)
  end

  def delete(conn, %{"id" => id}) do
    session = Accounts.get_session!(id)
    with {:ok, %Session{}} <- Accounts.delete_session(session) do
      send_resp(conn, :no_content, "")
    end
  end
end
