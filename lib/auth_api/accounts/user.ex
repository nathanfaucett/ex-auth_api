defmodule AuthApi.Accounts.User do
  use Ecto.Schema

  schema "accounts_users" do
    field :email, :string

    field :active, :boolean, default: true

    field :confirmation_token, :string
    field :confirmed, :boolean, default: false

    field :encrypted_password, :string

    has_many :sessions, AuthApi.Accounts.Session, on_delete: :delete_all
    has_many :accounts, AuthApi.Accounts.Application, on_delete: :nothing

    timestamps()
  end
end
