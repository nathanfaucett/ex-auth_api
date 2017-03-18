defmodule AuthApi.Plugs.AuthenticateUser do
  use Phoenix.Controller

  alias AuthApi.Accounts

  plug AuthApi.Plugs.AuthenticateApplication


  def init(default), do: default

  def call(conn, _default) do
    session = Accounts.get_session_from_conn(conn)

    if session != nil do
      current_user = Accounts.get(session.user_id)
      assign(conn, :current_user, current_user)
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(AuthApi.Web.ErrorView)
      |> render("401.json")
      |> halt
    end
  end
end
