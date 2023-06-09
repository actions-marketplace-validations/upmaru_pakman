defmodule Pakman.Deploy.Templates do
  require EEx

  @prefix "lib/pakman/templates/deploy"

  EEx.function_from_file(
    :def,
    :local_d_setup,
    Path.join(@prefix, "setup.eex"),
    [
      :name,
      :ref,
      :package_token
    ]
  )
end
