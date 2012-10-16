#!/usr/bin/env ruby

# Circular Linked list - ADT
class Node
  attr_accessor :value, :nxt
  def initialize(value=nil,nxt=nil)
    @value = value
    @nxt = nxt
  end
end
class CircularLinkedList
  def initialize(i)
    # last_node will always point to the most recent node added.
    @last_node = Node.new(i)
    # to get started it points to itself
    @last_node.nxt = @last_node
  end
  def append(i)
    # add the new node, and make it point to the "first-added" node,
    # whatever is considered to be the "head"
    @last_node.nxt = Node.new(i,@last_node.nxt)
    # Move the last node to point to the newest one created
    @last_node = @last_node.nxt
  end
  def head
    # Officially, this is one before head, but we aren't keeping previous,
    # so we have to do it this way
    @last_node
  end
  def traverse
    # Point to the "head" node
    x = head.nxt
    p "Begin the traverse at #{x.value}"
    # Loop until we reach the head node
    begin
      p x.value
      x = x.nxt
    end while x != head.nxt
  end
  # provide a pointer to the "head" node
  def set_ptr(p)
    @node = p
  end
  def next
    @node = @node.nxt
  end
  def peek
    @node.nxt
  end
  def current
    @node
  end
  def remove_next
    # move last_node ptr to this one, if we're going to remove the
    # last node
    @last_node = @node if @node.nxt == @last_node
    @node.nxt = @node.nxt.nxt
  end
end
