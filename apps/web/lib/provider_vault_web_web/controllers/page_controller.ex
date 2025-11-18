defmodule ProviderVaultWebWeb.PageController do
  use ProviderVaultWebWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
