defmodule ProviderVaultWeb.Repo do
  use Ecto.Repo,
    otp_app: :provider_vault_web,
    adapter: Ecto.Adapters.Postgres
end
