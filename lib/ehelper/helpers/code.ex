defmodule Ehelper.Code do
  @moduledoc """
  Code helpers
  Interface to the Erlang code server process.

  - https://hexdocs.pm/elixir/Code.html
  - https://www.erlang.org/doc/apps/kernel/code.html
  """

  def otp_root, do: :code.root_dir()

  @doc """
  - https://www.erlang.org/doc/apps/kernel/code.html#module-code-path
  """
  def paths, do: :code.get_path()

  def lib_dir(lib \\ :elixir), do: :code.lib_dir(lib)

  def which(mod), do: :code.which(mod)

  @doc """
  :interactive (default) or :embeded by `erl -mode embedded`
  - https://www.erlang.org/doc/apps/kernel/code.html#get_mode/0
  - In interactive mode, which is default, only the modules needed by the runtime system are loaded during system startup. Other code is dynamically loaded when first referenced. When a call to a function in a certain module is made, and that module is not loaded, the code server searches for and tries to load that module.
  - In embedded mode, modules are not auto-loaded. Trying to use a module that has not been loaded results in an error. This mode is recommended when the boot script loads all modules, as it is typically done in OTP releases. (Code can still be loaded later by explicitly ordering the code server to do so).
  """
  def mode, do: :code.get_mode()

  defdelegate clash, to: :code
  defdelegate all_loaded, to: :code

  @doc """
  iex>  Code.require_file("run/demo.exs")
  """
  def required_files() do
    Code.required_files()
    # |> Enum.sort()
  end

  @doc """
  - https://hexdocs.pm/elixir/Code.html#put_compiler_option/2
  """
  def compiler_opts do
    [
      current: Code.compiler_options(),
      available: Code.available_compiler_options() |> Enum.sort()
    ]
  end
end
