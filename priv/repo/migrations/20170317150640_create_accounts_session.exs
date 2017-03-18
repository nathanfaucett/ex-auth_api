defmodule AuthApi.Repo.Migrations.CreateAuthApi.Accounts.Session do
  use Ecto.Migration

  def change do
    create table(:accounts_sessions) do
      add :token, :string
      add :user_id, references(:accounts_users, on_delete: :nothing)

      timestamps()
    end

    create index(:accounts_sessions, [:token])
  end
end
