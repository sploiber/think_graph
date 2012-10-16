#!/usr/bin/env ruby
require 'set'
require './DoublyLinkedList'

# From Think Complexity, Chapter 2 - using a Graph to explore computational
# complexity.
# The book is Python, and we are using Ruby here.

# Link represents the linked list
class Link
  attr_accessor :value, :nxt
  def initialize(value=nil,nxt=nil)
    @value = value
    @nxt = nxt
  end
end

class Graph
  # Adjacency lists representation. Maintain an array of vertices, and
  # a Hash of linked lists, each representing all connected nodes of a 
  # particular vertex.
  # @vertices is the array of vertices
  # @adj_lists is a Hash of linked lists, each containing all connected nodes
  # of the given vertex
  # We will also keep the adjacency matrix, for computing Watts-Strogatz
  # quantities. We also keep the distance matrix, for running Dijkstra.
  def initialize
    @vertices = []
    @adj_lists = {}
    @adj_matrix = Set.new
    @distance_matrix = Array.new
  end

  def add_vertex(v)
    # no benefit from using Array instead of Set here, yet
    @vertices.push(v) unless @vertices.include? v
  end

  def add_edge(u,v)
    # undirected graph
    append_edge(u,v)
    append_edge(v,u)
    key1 = "#{u}|#{v}"
    key2 = "#{v}|#{u}"
    @adj_matrix.add? key1
    @adj_matrix.add? key2
  end

  # #4 in the book, page 13: remove an edge between given vertices
  def remove_edge(u,v)
    delete_edge(u,v)
    delete_edge(v,u)
    key1 = "#{u}|#{v}"
    key2 = "#{v}|#{u}"
    @adj_matrix.delete? key1
    @adj_matrix.delete? key2
  end
  # #5 in the book, page 13
  def vertices
    @vertices
  end
  # #6 in the book, page 13 - simple list of all edges. Note that [a,b] and
  # [b,a] will both be listed.
  def edges
    r = []
    s = []
    @adj_lists.each do |key, val|
      if val != nil
        s = [key, val.value]
        r << s
        z = val
        while z.nxt != nil
          z = z.nxt
          r << [key, z.value]
        end
      end
    end
    r
  end
  # #7 in the book, page 13 - provide list of vertices associated with a
  # vertex by edges
  def out_vertices(v)
    r = []
    if @adj_lists[v]
      z = @adj_lists[v]
      r << z.value
      while z.nxt != nil
        z = z.nxt
        r << z.value
      end
    end
    r
  end
  # #8 in the book - provide all edges connected to a given vertex
  def out_edges(v)
    r = []
    s = []
    @adj_lists.each do |key, val|
      if val != nil
        s = [key, val.value]
        r << s if (v == key || v == val.value)
        z = val
        while z.nxt != nil
          z = z.nxt
          r << [key, z.value] if v == key
        end
      end
    end
    r
  end
  def is_edge?(u,v)
    key = "#{u}|#{v}"
    @adj_matrix.include? key
  end
  # Make a complete graph
  def add_all_edges
    @vertices.each_with_index do |a,i|
      (0..(i-1)).each { |j| add_edge(@vertices[i], @vertices[j]) }
    end
  end
  def is_connected?
    # Odd that Queue is stuck in Thread. We can use Array#shift to pop off
    # the front. Here, we used a partially-implemented DoublyLinkedList to
    # handle the Queue/fifo functionality.
    q = DoublyLinkedList.new
    # marked list is a set
    s = Set.new
    # choose first one to explore with
    q.push(@vertices[0])
    while not q.is_empty?
      # pop the front of the queue, and add possible connections to the
      # list of all connected vertices.
      z = q.pop
      s.add z
      out_vertices(z).each { |a| q.push(a) if not s.include? a }
    end
    return true if s.size == @vertices.size
    false
  end
  def get_cc
    # Now traverse and compute the fraction of existing edges
    # For node x, we need all its neighbors, but we need all pairs 
    # of its neighbors with each other .
    total = 0
    @vertices.each do |i|
      sum = 0
      r = out_vertices(i)
      r.each do |j|
        r.each do |k|
          key = "#{j}|#{k}"
          sum += 1 if @adj_matrix.include? key
        end
      end
      total += 2.0*sum/(r.size*(r.size-1))
    end
    total/@vertices.size
  end
  def dijkstra

    @vertices.each do |v|

      q = DoublyLinkedList.new
      @distance_matrix[v] = Array.new
      @vertices.each { |i| @distance_matrix[v][i] = -1 }

      # choose first one to explore with
      q.push(v)
      @distance_matrix[v][v] = 0
      while not q.is_empty?
        z = q.pop
        d = @distance_matrix[v][z]
        out_vertices(z).each do |a|
          if @distance_matrix[v][a] == -1 
            q.push(a)
            @distance_matrix[v][a] = d + 1
          end
        end
      end
    end
  end
  def get_l
    sum = 0
    total = 0
    @vertices.each do |i|
      @vertices.each do |j|
        if i != j
          sum += @distance_matrix[i][j]
          total += 1
        end
      end
    end
    0.5*sum/total
  end
private
  def delete_edge(x1,x2)
    # Check that there are edges associated with this vertex
    if @adj_lists[x1]
      z = @adj_lists[x1]
      if x2 == z.value and z.nxt != nil
        # If we've found the right one, get rid of it
        @adj_lists[x1] = @adj_lists[x1].nxt
      elsif x2 == z.value and z.nxt == nil
        # If we found the right one, and nothing remains after it, we have
        # exhausted the list of connected vertices.
        @adj_lists[x1] = nil
      else
        # Go until we find the one we're looking for
        while (z.nxt != nil) and (z.nxt.value != x2) do
          z = z.nxt 
        end
        # Delete; a little concerned that we must have found something.
        z.nxt = z.nxt.nxt
      end
    end
  end
  def append_edge(x1,x2)
    if not @adj_lists[x1]
      # Initialize, with the first connected vertex, if none were there
      @adj_lists[x1] = Link.new(x2)
    else
      z = @adj_lists[x1]
      # Either we hit the end of the list, or we hit the element we were
      # looking for. If we hit the element, we don't need to add the edge
      # again; if we do, we add the edge. We don't want to add an edge
      # twice.
      if z.value != x2
        while (z.nxt != nil) and (z.nxt.value != x2)
          z = z.nxt
        end
        z.nxt = Link.new(x2) if z.nxt == nil
      end
    end
  end
end
