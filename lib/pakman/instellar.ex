defmodule Pakman.Instellar do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "http://localhost:4000")
  plug(Tesla.Middleware.JSON)

  alias Tesla.Multipart

  def authenticate do
    auth_token = System.get_env("INSTELLAR_AUTH_TOKEN")

    case post("/auth/automation/callback", %{auth_token: auth_token}) do
      {:ok, %{status: 201, body: body}} -> {:ok, body["data"]["token"]}
      {:ok, %{status: 404}} -> {:error, :not_found}
    end
  end

  def create_deployment(token, archive_path) do
    package_token = System.get_env("INSTELLAR_PACKAGE_TOKEN")
    hash = System.get_env("GITHUB_SHA")
    ref = System.get_env("GITHUB_REF")

    headers = [
      {"authorization", "Bearer #{token}"},
      {"x-instellar-package-token", package_token}
    ]

    multipart =
      Multipart.new()
      |> Multipart.add_content_type_param("application/x-www-form-urlencoded")
      |> Multipart.add_file(archive_path, name: "deployment[archive]")
      |> Multipart.add_field("deployment[ref]", ref)
      |> Multipart.add_field("deployment[hash]", hash)

    post("/publish/deployments", multipart, headers: headers)
  end
end
