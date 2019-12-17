defmodule Apkify.Bootstrap do
  alias Apkify.Templates

  def perform(options) do
    [namespace, name] =
      options
      |> Keyword.get(:repository)
      |> String.split("/")

    version = Keyword.get(options, :version)
    build = Keyword.get(options, :build)
    depends = Keyword.get(options, :depends)
    makedepends = Keyword.get(options, :makedepends)

    base_path =
      ~s(GITHUB_WORKSPACE)
      |> System.get_env()
      |> Path.join(".apk/#{namespace}/#{name}")

    System.cmd("chown", ["-R", "builder:abuild", System.get_env("GITHUB_WORKSPACE")])

    File.mkdir_p!(base_path)

    create_apkbuild(base_path, name, version, build, depends, makedepends)
    create_file(base_path, name, :initd)
    create_file(base_path, name, :profile)
  end

  defp create_apkbuild(base_path, name, version, build, depends, makedepends) do
    [base_path, "APKBUILD"]
    |> Enum.join("/")
    |> File.write(Templates.apkbuild(name, version, build, depends, makedepends))
  end

  defp create_file(base_path, name, extension) do
    [base_path, "#{name}.#{extension}"]
    |> Enum.join("/")
    |> File.write(apply(Templates, extension, [name]))
  end
end
