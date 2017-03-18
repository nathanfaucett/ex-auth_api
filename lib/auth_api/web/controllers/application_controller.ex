defmodule AuthApi.Web.ApplicationController do
  use AuthApi.Web, :controller

  alias AuthApi.Accounts
  alias AuthApi.Accounts.Application

  action_fallback AuthApi.Web.FallbackController

  plug AuthApi.Plugs.AuthenticateUser when action in
    [:index, :create, :show, :update, :delete]

  def index(conn, _params) do
    applications = Accounts.list_applications(conn.assigns[:current_user].id)
    render(conn, "index.json", applications: applications)
  end

  def create(conn, %{"application" => application_params}) do
    with {:ok, %Application{} = application} <- Accounts.create_application(
      Map.put(application_params, "owner_id", conn.assigns[:current_user].id)
    ) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", application_path(conn, :show, application))
      |> render("show.json", application: application)
    end
  end

  def show(conn, %{"id" => id}) do
    application = Accounts.get_application!(id)
    render(conn, "show.json", application: application)
  end

  def update(conn, %{"id" => id, "application" => application_params}) do
    application = Accounts.get_application!(id)

    with {:ok, %Application{} = application} <- Accounts.update_application(application, application_params) do
      render(conn, "show.json", application: application)
    end
  end

  def delete(conn, %{"id" => id}) do
    application = Accounts.get_application!(id)
    with {:ok, %Application{}} <- Accounts.delete_application(application) do
      send_resp(conn, :no_content, "")
    end
  end
end
