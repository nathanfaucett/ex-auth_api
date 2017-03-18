defmodule AuthApi.Accounts.Application do
  use Ecto.Schema

  schema "accounts_applications" do
    field :name, :string
    field :token, :string
    belongs_to :owner, AuthApi.Accounts.User

    timestamps()
  end
end
