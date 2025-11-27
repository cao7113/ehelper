defmodule ConnectHooks do
  def connect(info) do
    {:ok, [:hooks | info]}
  end

  defmacro __using__(_opts) do
    quote do
      def connect(info), do: {:ok, [:default | info]}

      # 允许用户覆盖上面的默认connect实现
      defoverridable connect: 1

      # 在用户模块编译前插入，如有用户重定义connect，则在这个调用之前执行
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(%{module: _mod} = _env) do
    quote do
      # 注意两次 defoverridable的区别
      # 关键区别：作用对象不同
      # 声明位置 作用对象​ 目的​
      # __using__内 用户自定义函数 允许用户覆盖默认实现
      # __before_compile__内 框架注入的函数 使注入的函数可通过 super 调用上层
      defoverridable connect: 1

      # 最后插入编译前的用户模块代码，super指代 编译前的可能版本：默认或 用户自定义版本（如果用户提供了connect版本）
      def connect(info) do
        with {:ok, new_info} <- super(info) do
          ConnectHooks.connect(new_info)
        end
      end
    end
  end
end

defmodule UseHooksNoConnect do
  use ConnectHooks
end

defmodule UseHooksConnect do
  use ConnectHooks

  def connect(info) do
    {:ok, [:user | info]}
  end
end

defmodule SuperTest do
  @moduledoc """
  - https://github.com/phoenixframework/phoenix_live_view/blob/v1.1.18/lib/phoenix_live_view/socket.ex#L105

  精妙的协作设计: 这种设计模式在 Elixir/Phoenix 中很常见（如控制器、通道等），体现了"约定优于配置"和"可扩展性优先"的哲学。

  考虑这个执行顺序：
  用户模块编译开始
  执行 use Phoenix.LiveView.Socket
  展开宏：
  定义默认 connect/3
  第一次 defoverridable（声明用户可覆盖）
  用户可能添加自定义 connect/3
  编译结束前触发 @before_compile
  展开注入代码：
  第二次 defoverridable（声明框架注入函数可覆盖）
  定义新的 connect/3
  """

  use ExUnit.Case

  test "super and before_compile" do
    assert UseHooksNoConnect.connect([]) == {:ok, [:hooks, :default]}
    assert UseHooksConnect.connect([]) == {:ok, [:hooks, :user]}
  end
end

defmodule ABehaviour do
  @callback test(number(), number()) :: number()
end

defmodule DefaultMod do
  defmacro __using__(_opts) do
    quote do
      @behaviour ABehaviour

      def test(x, y) do
        x + y
      end

      defoverridable ABehaviour
    end
  end
end

defmodule ChildMod do
  use DefaultMod

  def test(x, y) do
    x * y + super(x, y)
  end
end
