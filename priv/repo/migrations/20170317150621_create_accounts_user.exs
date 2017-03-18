defmodule AuthApi.Repo.Migrations.CreateAuthApi.Accounts.User do
  use Ecto.Migration

  def change do
    create table(:accounts_users) do
      add :email, :string

      add :active, :boolean, default: true, null: false

      add :confirmed, :boolean, default: false, null: false
      add :confirmation_token, :string

      add :encrypted_password, :string

      timestamps()
    end

    create unique_index(:accounts_users, [:email])
  end
end
