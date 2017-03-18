defmodule AuthApi.Web.UserController do
  use AuthApi.Web, :controller

  alias AuthApi.Accounts
  alias AuthApi.Accounts.User

  action_fallback AuthApi.Web.FallbackController

  plug AuthApi.Plugs.AuthenticateApplication when action in [:create]
  plug AuthApi.Plugs.AuthenticateUser when action in
    [:show, :update, :delete, :resend_confirmation_token, :confirm]


  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create(user_params) do
      mail = AuthApi.Email.confirmation_html_email(%{
        email: user.email,
        token: user.confirmation_token
      })

      if Mix.env == :prod do
        AuthApi.Mailer.deliver_later(mail)
      else
        AuthApi.Mailer.deliver_now(mail)
      end

      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get!(id)

    with {:ok, %User{} = user} <- Accounts.update(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get!(id)
    with {:ok, %User{}} <- Accounts.delete(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def resend_confirmation_token(conn, _params) do
    with {:ok, %User{} = user} <- Accounts.new_confirmation_token(conn.assigns[:current_user]) do
      mail = AuthApi.Email.confirmation_html_email(%{
        email: user.email,
        token: user.confirmation_token
      })

      if Mix.env == :prod do
        AuthApi.Mailer.deliver_later(mail)
      else
        AuthApi.Mailer.deliver_now(mail)
      end

      conn
      |> put_status(:no_content)
      |> json("")
      |> halt
    end
  end

  def confirm(conn, %{"token" => token}) do
    with {:ok, %User{}} <- Accounts.confirm(conn.assigns[:current_user], token) do
      conn
      |> put_status(:no_content)
      |> json("")
      |> halt
    end
  end
end
