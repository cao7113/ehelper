# defprotocol Size do
#   def size(_)
# end

# defimpl Size, for: BitString do
#   def size(s) do
#     byte_size(s)
#   end
# end

# defimpl Size, for: Map do
#   def size(m), do: map_size(m)
# end

# defimpl Size, for: Tuple do
#   def size(t), do: tuple_size(t)
# end

# # Size.size("abc")
# # Size.__protocol__ :functions
# # Size.__protocol__ :module

# # Enumerable.__protocol__(:functions)
