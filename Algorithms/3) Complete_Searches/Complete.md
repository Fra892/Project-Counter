# Backtracking and Complete Searches
When solving a problem, one brute-force approach is to enumerate all possible solutions and select the best among them. This approach, known as complete search, is sometimes the only viable method — especially in problems that ask for all permutations, combinations, or subsets. While complete search generally has exponential time complexity, it's a valid approach when the input size is small or when time constraints are relaxed.

To improve efficiency in practice, we often use a technique called backtracking. While backtracking still explores the entire solution space, it prunes parts of the search tree that cannot possibly lead to valid or optimal solutions, thereby reducing the number of recursive calls and improving performance.

Let’s consider the example of generating all subsets of a set S. Each subset is defined by a sequence of binary choices: for each element, we decide whether to include it or not. This process naturally forms a decision tree, where each node represents a partial solution, and each level corresponds to a choice for one element.

In more complex problems, each step may offer multiple choices, and the decision process forms a state space tree or search graph. To explore this graph, we typically use depth-first search (DFS) because it aligns well with recursive backtracking.

Now, can we reduce the time spent exploring this decision graph?

Yes — by using constraints or problem-specific properties to prune branches of the tree. If a partial solution already violates a constraint, we can abandon that branch early. This is the core idea behind backtracking: don't explore what can't possibly work.

Backtracking is powerful because it combines the completeness of brute-force search with practical optimizations that drastically reduce runtime in many real-world cases.


# Subsets
Declaration: Given an array of integers nums representing a set, return an array containing all possible subset of the set nums. Order is not important.
```cpp
void dfs(auto& ret, auto& subset, auto& nums, int idx){
  if(idx >= nums.size()){
    ret.push_back(subset);
    return;
  }
  for(int i = idx; i < nums.size(); i++){
    subset.push_back(nums[i]);
    // accept choice
    dfs(ret, subset, nums, i + 1);
    subset.pop_back();
    // reject choice
  }
}


vector<vector<int>> find_subsets(vector<int>& nums){
  vector<vector<int>> ret;
  vector<int> subset;
  int idx = 0;
  dfs(ret, subset, nums, idx);
  return ret;
  
}
```
This code shows the implementation using the classic dfs structure.
We note that there is no pruning here, let's now see a problem where backtracking comes into play.

# NQueens
The n-queens puzzle is the problem of placing n queens on an n x n chessboard such that no two queens attack each other.

Given an integer n, return all distinct solutions to the n-queens puzzle. You may return the answer in any order.

Each solution contains a distinct board configuration of the n-queens' placement, where 'Q' and '.' both indicate a queen and an empty space, respectively.

```cpp
void search_space(auto& grid, auto& ret, const int& N, int put, auto& queen_pos){
  // stop condition we put four queens 
  // putting a queen in some place of a row is the same thing as processing the row itself
  if(put == N){
    ret.push_back(grid);
    return;
  }
  // iterate the row
  for(int i = 0; i < N; i++){
    bool found = false;
    for(const auto& pos : queen_pos){
      int c_d = pos.first - pos.second;
      int c_a = pos.first + pos.second;
      int col = pos.second;
      if(col == i || c_d == put - i|| c_a == put + i){
        found = true;
        break;
      }
    }
    if(found)
      continue;
    queen_pos[put] = i;
    grid[put][i] = 'Q';
    search_space(grid, ret, N, put + 1, queen_pos);
    grid[put][i] = '.';
    queen_pos.erase(put);
  }
}

vector<vector<string>> solveNQueens(int n) {
  // create the grid
  vector<string> grid(n, string(n, '.'));
  vector<vector<string>> ret = {};
  unordered_map<int,int> queen_pos;
  int put = 0;
  search_space(grid, ret, n, put, queen_pos);
  return ret;
}

```







