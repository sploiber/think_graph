#!/usr/bin/env ruby

# From Think Complexity, Chapter 4 - FIFO
# want to implement a first-in-first-out structure
# operations are:
#   push(item) - push onto the end of the list
#   pop - remove the item at the top of the list, and return it

# We will do this as a doubly-linked list
# The data structure has a value and prev and nxt pointers;
# we will store both the first and last nodes of the list
# This is only 2 of the operations that are actually part of a complete
# doubly linked list.

class Node
  attr_accessor :value, :prev, :nxt
  def initialize(value=nil,prev=nil,nxt=nil)
    @value = value
    @prev = prev
    @nxt = nxt
  end
end
class DoublyLinkedList
  def initialize
  end
  def push(i)
    if not @first_node
      @first_node = Node.new(i)
      @last_node = @first_node
    else
      x = Node.new(i,@last_node,nil)
      @last_node.nxt = x
      @last_node = x
    end
  end
  def pop
    if @first_node
      n = @first_node
      if n.nxt
        # If there is a next
        n.nxt.prev = nil
        @first_node = n.nxt
      else
        @first_node = nil
        @last_node = nil
      end
      return n.value
    end
    nil
  end
  def is_empty?
    (@first_node.nil? && @last_node.nil?) ? true : false
  end
  def traverse
    if @first_node
      z = @first_node
      begin
        p z.value
        z = z.nxt
      end while z != nil
    end
  end
end
