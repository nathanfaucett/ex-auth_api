defmodule AuthApi.Web.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use AuthApi.Web, :controller


  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(AuthApi.Web.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(AuthApi.Web.ErrorView, :"404")
  end

  def call(conn, {:unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> render(AuthApi.Web.ErrorView, :"401")
  end
end
