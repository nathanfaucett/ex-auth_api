defmodule AuthApi.Plugs.AuthenticateApplication do
  use Phoenix.Controller
  use AuthApi.Web, :controller

  alias AuthApi.Accounts


  def init(default), do: default

  def call(conn, _default) do
    application = Accounts.get_application_from_conn(conn)

    if application != nil do
      assign(conn, :current_application, application)
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(AuthApi.Web.ErrorView)
      |> render("401.json")
      |> halt
    end
  end
end
