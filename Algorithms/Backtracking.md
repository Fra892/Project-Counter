# Backtracking and Complete Searches
Let's think of any problem, a way to solve this is always to enumerate all the solutions possible and selecting the best while doing so.
This approach could be useful if there's enough time to go through all the possible solutions, it's trivial that for problems that ask to generate
permutation or subset, there's no other efficient way. A complete search is always a viable option if we are not worried about time constraints.
Even though a complete search algorithm has always an exponantial-time complexity backtracking is a technique that in practice can reduce by a lot the number of 
recursive calls, therefore reducing the running time. Any solution to any problems is made out of choices that impacts the final solution, for example let's say we
wanna enumerate all the subset of a set s. Every subset is a choice of including or not including an element. This process forms a tree, a decision tree. Sometimes at every step
there are more than one choice. To explore this graph, a dfs is usually employed. Now let's return to the initial problem, given the constraint the a solution 
has to follow, is there any way to reduce the explore time of this graph. Yes, usually there are property that can be exploited to cut branches off the tree, this 
will never be explored
