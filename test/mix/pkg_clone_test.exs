# defmodule Mix.Tasks.H.Pkg.CloneTest do
#   use ExUnit.Case, async: false

#   import ExUnit.CaptureIO

#   alias Mix.Tasks.H.Pkg.Clone

#   setup do
#     cache_root =
#       Path.join(
#         System.tmp_dir!(),
#         "ehelper-pkg-clone-cache-#{System.unique_integer([:positive])}"
#       )

#     previous_cache_root = System.get_env("MIX_PKGS_INFO_ROOT")
#     System.put_env("MIX_PKGS_INFO_ROOT", cache_root)
#     File.mkdir_p!(cache_root)

#     on_exit(fn ->
#       if previous_cache_root do
#         System.put_env("MIX_PKGS_INFO_ROOT", previous_cache_root)
#       else
#         System.delete_env("MIX_PKGS_INFO_ROOT")
#       end

#       File.rm_rf!(cache_root)
#     end)

#     {:ok, cache_root: cache_root}
#   end

#   test "shallow-clones into the current directory and skips an existing package", %{
#     cache_root: cache_root
#   } do
#     package = "sample_pkg"
#     source = create_bare_repo()
#     source_url = "file://#{source}"
#     destination_root = temp_path("pkg-clone-default")
#     destination = Path.join(destination_root, package)

#     on_exit(fn ->
#       File.rm_rf!(destination_root)
#       File.rm_rf!(source)
#     end)

#     File.mkdir_p!(destination_root)
#     write_cached_package(cache_root, package, source_url)

#     output =
#       capture_io(fn ->
#         File.cd!(destination_root, fn ->
#           Clone.run([package, "--depth", "1"])
#           Clone.run([package])
#         end)
#       end)

#     assert File.dir?(Path.join(destination, ".git"))
#     assert output =~ "Cloning #{source_url} into"
#     assert output =~ "#{package} already exists"
#   end

#   test "clones into an explicit destination", %{cache_root: cache_root} do
#     package = "sample_pkg"
#     source = create_bare_repo()
#     source_url = "file://#{source}"
#     destination_root = temp_path("pkg-clone-custom")

#     on_exit(fn ->
#       File.rm_rf!(destination_root)
#       File.rm_rf!(source)
#     end)

#     write_cached_package(cache_root, package, source_url)

#     Clone.run([package, destination_root, "--depth", "2"])

#     assert File.dir?(Path.join([destination_root, package, ".git"]))
#   end

#   test "fails clearly when the Hex metadata has no GitHub URL", %{cache_root: cache_root} do
#     package = "sample_pkg"
#     destination = temp_path("pkg-clone-no-url")
#     on_exit(fn -> File.rm_rf!(destination) end)
#     File.write!(Path.join(cache_root, "#{package}.json"), JSON.encode!(%{"name" => package}))

#     assert_raise Mix.Error, ~r/No GitHub URL found/, fn ->
#       Clone.run([package, destination])
#     end
#   end

#   defp create_bare_repo do
#     path = temp_path("pkg-clone-source")
#     File.mkdir_p!(Path.dirname(path))
#     {_, 0} = System.cmd("git", ["init", "--bare", path], stderr_to_stdout: true)
#     path
#   end

#   defp write_cached_package(cache_root, package, github_url) do
#     body = %{"name" => package, "meta" => %{"links" => %{"GitHub" => github_url}}}
#     File.write!(Path.join(cache_root, "#{package}.json"), JSON.encode!(body))
#   end

#   defp temp_path(prefix) do
#     Path.join(System.tmp_dir!(), "#{prefix}-#{System.unique_integer([:positive])}")
#   end
# end
