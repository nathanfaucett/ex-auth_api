defmodule AuthApi.Accounts.Session do
  use Ecto.Schema

  schema "accounts_sessions" do
    field :token, :string
    belongs_to :user, AuthApi.Accounts.User

    timestamps()
  end
end
