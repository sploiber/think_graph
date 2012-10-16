#!/usr/bin/env ruby
require './Graph'

# Watts/Strogatz model [WS] - starting with a ring lattice.
# n is number of vertices
# k is the number of nearest connected neighbors in a ring lattice.
# p is the probability of re-wiring an individual edge

# If I run with n = 1000, k = 40, and 1/p = 10, I get .735.
# The same ballpark is reached with k = 20 and k = 10.
# The p number has a much more significant effect, as it should, controlling
# the number of introduced randomness.
# For (1000,20,100) I get 0.97, which is p = 0.01.

# They say n >> k >> ln n >> 1, so that the graph is not in danger of being
# disconnected. For n = 1000, ln n ~ 7, so k = 40 is a reasonable number.
# at (1000,40,1) => C = 1.462, p = 0 => the ratio of C is 1 (as expected)
#   (the code triggers on 1, and rand(1) will never equal 1)
# at (1000,40,2) => C = 1.462, p = 0.5 => ratio C is 0.164
# at (1000,40,4) => C = 1.462, p = 0.25 => ratio C is 0.44
# at (1000,40,8) => C = 1.462, p = 0.125 => ratio C is 0.67
# at (1000,40,10) => C = 1.462, p = 0.1 => ratio C is 0.74
# at (1000,40,20) => C = 1.462, p = 0.05 => ratio C is 0.87
# at (1000,40,50) => C = 1.462, p = 0.02 => ratio C is 0.95
# at (1000,40,100) => C = 1.462, p = 0.01 => ratio C is 0.97
# at (1000,80,p=1) I got ratio 0.11 (not sure)
# at (1000,40,p=1) I got ratio 0.055 (not sure)
# at (1000,20,p=1) I got ratio 0.028 (not sure)
# if I divide them all by 1.4, though, I get the same number in all cases.
# in the limit of p going to 1, they say k/n for C.
# In the limit of p going to zero, they say C ~ 3/4, and I see that with a
# factor of 2. (which still has to be worked out)
# For k/n, it would be 40/1000, hmm.
n = ARGV[0].to_i
k = ARGV[1].to_i
p = ARGV[2].to_i

g = Graph.new
# Create vertices in the graph
(1..n).each { |a| g.add_vertex(a) }
# Create edges to form ring lattice. For k = 4, for example, each vertex
# will have 2 nearest neighbors in either direction.
(1..n).each do |i|
  (1..(k/2)).each do |j|
    l = (i + j) % n
    b = (l == 0 ? n : l)
    g.add_edge(i,b)
  end
end

# Now prepare for the random re-wirings. Form arrays of nearest neighbors,
# sorted "clockwise", as required in [WS]. After we get the sorted list of
# nearest neighbors, we have to re-order them so that the "earlier" ones are
# in proper order.
neighborz = Array.new
(1..n).each do |i|
  neighborz[i] = Array.new
  neighborz[i] = g.out_vertices(i).sort
  if i < n
    while neighborz[i][0] < i
      neighborz[i].push(neighborz[i].shift)
    end
  end
end

# Compute the clustering coefficient C(p) for the regular lattice, before we
# start re-wiring edges.
base_lattice = g.get_cc
p base_lattice
g.dijkstra
base_ell = g.get_l
p base_ell

# Loop over all edges, and each one, decide whether or not to re-write it.
(1..(k/2)).each do |i|
  (1..n).each do |j|

    # This is perhaps not the best way to implement probability, but it seemed
    # that counting iterations would keep hitting the same vertex.
    #if 1
    if rand(p) == 1
      # [WS] does not discuss it, but the question is whether the list of
      # nearest-neighbors is altered if you add a random edge. Naively, it
      # seems like it would be, and you would possibly move the same vertex
      # more than once.
      g.remove_edge(j,neighborz[j][i-1])

      # this little snippet finds a new edge, by rejecting edges which are
      # already present. Then, add the new edge.
      begin
        z = rand(n) + 1
      end while g.is_edge?(j,z)
      g.add_edge(j,z)

    end
  end
end
p g.get_cc/base_lattice

# Now, run Dijkstra
g.dijkstra
p g.get_l
