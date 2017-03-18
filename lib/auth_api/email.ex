defmodule AuthApi.Email do
  use Bamboo.Phoenix, view: AuthApi.Web.EmailView

  def confirmation_text_email(params = %{email: email, token: _token}) do
    new_email()
      |> to(email)
      |> from("admin@faucette.com")
      |> subject("Auth Confirmation Email")
      |> put_text_layout({AuthApi.Web.LayoutView, "email.text"})
      |> render("confirmation.text", params)
  end

  def confirmation_html_email(params = %{email: _email, token: _token}) do
    confirmation_text_email(params)
      |> put_text_layout({AuthApi.Web.LayoutView, "email.html"})
      |> render("confirmation.html", params)
  end
end
