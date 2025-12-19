# Erlang Archive

The Erlang archives are ZIP files with extension .ez

- https://www.erlang.org/doc/apps/kernel/code.html#module-loading-of-code-from-archive-files


Erlang/Elixir 的 archives（归档文件，通常指 .ez 文件，或在 Elixir 中通过 mix archive.install 安装的归档）

!!!不能包含第三方依赖。它们只能依赖 Erlang/OTP 和 Elixir 的标准库。 

原因在于：
- 命名冲突：归档文件通常用于安装 Mix 任务或全局工具。它们与用户的应用程序加载到同一个 BEAM 虚拟机 (VM) 中。如果归档文件包含了特定版本的第三方库（例如 jason），而用户的项目又依赖了另一个不同版本的同一个库，就会导致版本冲突，因为在同一个 VM 中，一个应用只能加载一个特定版本的库。
- 设计目的：归档文件的设计目的是扩展 Mix 工具本身，而不是作为可部署的独立应用包。 


