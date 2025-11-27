defmodule EtsTest do
  @moduledoc """
  - https://www.erlang.org/doc/apps/stdlib/ets.html#new/2
  """
  use ExUnit.Case

  @moduletag :try

  test "non-named or named table" do
    ## Default opts when not specifying any options ([]) is the same as specifying
    # [set, protected, {keypos,1}, {heir,none}, {write_concurrency,false}, {read_concurrency,false}, {decentralized_counters,false}].
    tb = :ets.new(:t1, [])
    assert is_reference(tb)
    refute is_atom(tb)
    # can create many same name non-named tables
    tb = :ets.new(:t1, [])
    assert is_reference(tb)

    # named table return the atom name
    tb = :ets.new(:t2, [:named_table])
    # The function will also return the Name instead of the table identifier.
    assert tb == :t2
    # To get the table identifier of a named table, use whereis/1.
    ref = :ets.whereis(tb)
    assert is_reference(ref)

    # :named_table name cannot be re-used
    assert_raise ArgumentError, ~r/1st argument: table name already exists/, fn ->
      :ets.new(:t2, [:named_table])
    end
  end

  # Data is organized as a set of dynamic tables, which can store tuples. Each table is created by a process. When the process terminates, the table is automatically destroyed. Every table has access rights set at creation.

  # The table identifier can be sent to other processes so that a table can be shared between different processes within a node.
  # non-private

  # Notice that there is no automatic garbage collection for tables. Even if there are no references to a table from any process, it is not automatically destroyed unless the owner process terminates. To destroy a table explicitly, use function delete/1. The default owner is the process that created the table. To transfer table ownership at process termination, use option heir or call give_away/3.

  # Bag Table 是 ETS 中允许同一键对应多个唯一值的数据结构，适用于需要存储「单键多值」且值不重复的场景（如标签、事件记录）。它的核心价值是灵活管理同一实体的多维度数据，同时保持高效的读写性能（ETS 基于内存，读写复杂度接近 O(1)）。
end
