defmodule AuthApi.Repo.Migrations.CreateAuthApi.Accounts.Application do
  use Ecto.Migration

  def change do
    create table(:accounts_applications) do
      add :name, :string
      add :token, :string
      add :owner_id, references(:accounts_users, on_delete: :nothing)

      timestamps()
    end

    create index(:accounts_applications, [:name, :token])
  end
end
