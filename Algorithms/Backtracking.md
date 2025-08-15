# Backtracking and Complete Searches
When solving a problem, one brute-force approach is to enumerate all possible solutions and select the best among them. This approach, known as complete search, is sometimes the only viable method — especially in problems that ask for all permutations, combinations, or subsets. While complete search generally has exponential time complexity, it's a valid approach when the input size is small or when time constraints are relaxed.

To improve efficiency in practice, we often use a technique called backtracking. While backtracking still explores the entire solution space, it prunes parts of the search tree that cannot possibly lead to valid or optimal solutions, thereby reducing the number of recursive calls and improving performance.

Let’s consider the example of generating all subsets of a set S. Each subset is defined by a sequence of binary choices: for each element, we decide whether to include it or not. This process naturally forms a decision tree, where each node represents a partial solution, and each level corresponds to a choice for one element.

In more complex problems, each step may offer multiple choices, and the decision process forms a state space tree or search graph. To explore this graph, we typically use depth-first search (DFS) because it aligns well with recursive backtracking.

Now, can we reduce the time spent exploring this decision graph?

Yes — by using constraints or problem-specific properties to prune branches of the tree. If a partial solution already violates a constraint, we can abandon that branch early. This is the core idea behind backtracking: don't explore what can't possibly work.

Backtracking is powerful because it combines the completeness of brute-force search with practical optimizations that drastically reduce runtime in many real-world cases.


# Subsets
'''cpp
void dfs(auto& ret, auto& subset, auto& nums, int idx){
  if(idx >= nums.size()){
    ret.push_back(subset);
    return;
  }
  for(int i = idx; i < nums.size(); i++){
    subset.push_back(nums[i]);
    dfs(ret, subset, nums, i + 1);
    subset.pop_back();
  }
}


vector<vector<int>> find_subsets(vector<int>& nums){
  vector<vector<int>> ret;
  vector<int> subset;
  int idx = 0;
  dfs(ret, subset, nums, idx);
  
}

'''


