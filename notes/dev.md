# Dev env

- https://danschultzer.com/posts/development-helpers-in-elixir


## .fetch file

-# Ignore .fetch files in case you like to edit your project deps locally.
-/.fetch

在 Elixir 的 Mix 项目中，.fetch 文件主要与 依赖管理缓存 有关。
1. .fetch 文件的作用
.fetch 文件通常出现在项目的 deps/ 目录下（例如 deps/some_dep/.fetch）。它的主要作用是标记依赖项是否已成功获取。
状态记录：Mix 使用这些小文件来记录该依赖项的获取状态。如果该文件存在且内容正确，mix deps.get 在下次运行时可能会跳过重复下载。
本地编辑保护：你提到的 Git 忽略规则 /.fetch 是为了防止这些临时的状态标记文件被提交到版本控制系统中。由于依赖项本身通常也不提交（除非你显式 vendoring），这些描述获取状态的元数据文件更不应该进入仓库。 
2. 为什么在 .gitignore 中看到它？
在某些社区模板或特定版本的 Mix 中，会将 /.fetch 放入 .gitignore。
允许本地修改：正如注释所言，如果你需要本地修改 deps/ 目录下的代码进行调试，忽略这些文件可以确保 Mix 的内部状态记录不会干扰你的版本管理。
环境一致性：不同开发者的机器可能会生成不同的 .fetch 时间戳或状态，忽略它们可以避免 Git 状态栏出现不必要的“未跟踪文件”提示。
3. 与项目的关系
不属于代码：它不是你的业务代码，也不包含任何逻辑。
可安全删除：如果你删除了 deps/ 目录或其中的 .fetch 文件，只需重新运行 mix deps.get，Mix 会重新生成它们并重新获取依赖。 
总结：这是 Mix 内部的管理标记文件，用于优化依赖获取流程。将其加入 .gitignore 是为了保持代码仓库的整洁，避免不同环境下构建元数据的冲突。

