defmodule AuthApi.Web.ApplicationView do
  use AuthApi.Web, :view
  alias AuthApi.Web.ApplicationView

  def render("index.json", %{applications: applications}) do
    %{data: render_many(applications, ApplicationView, "application.json")}
  end

  def render("show.json", %{application: application}) do
    %{data: render_one(application, ApplicationView, "application.json")}
  end

  def render("application.json", %{application: application}) do
    %{id: application.id,
      name: application.name,
      token: application.token}
  end
end
