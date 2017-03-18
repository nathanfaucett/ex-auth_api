defmodule AuthApi.Web.Router do
  use AuthApi.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AuthApi.Web do
    pipe_through :api

    resources "/users", UserController
    post "/users/resend_confirmation_token", UserController, :resend_confirmation_token
    post "/users/confirm/:token", UserController, :confirm

    resources "/users/sessions", SessionController

    resources "/applications", ApplicationController
  end
end
