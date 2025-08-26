## Complete Searches
When solving a problem, one brute-force approach is to enumerate all possible solutions and select the best among them. This approach, known as complete search, is sometimes the only viable method — especially in problems that ask for all permutations, combinations, or subsets. While complete search generally has exponential time complexity, it's a valid approach when the input size is small or when time constraints are relaxed.

Let’s consider the example of generating all subsets of a set S. Each subset is defined by a sequence of binary choices: for each element, we decide whether to include it or not. This process naturally forms a decision tree, where each node represents a partial solution, and each level corresponds to a choice for one element.

In more complex problems, each step may offer multiple choices, and the decision process forms a state space tree or search graph. To explore this graph, we typically use depth-first search (DFS) because it aligns well with recursive backtracking.

Tha aim of complete searches is to explore all the solutions to the problems to solve the problem. Every problem could be resolved with complete searches since we are analyzing the whole state space. As said this come with a tradeoff:
- Time-Complexity The algorithm has exponential time-complexity since it's analyzing all possible states.
- Memory-Complexity If implmented with recursion, the recursive calls allocated on the stack can cause stack overflow even for small instances with a moderate number of branches in the state space.
  
# Subsets
Declaration: Given an array of integers nums representing a set, return an array containing all possible subset of the set nums. Order is not important.
```cpp
void dfs(auto& ret, auto& subset, auto& nums, int idx){
  // stop condition
  if(idx >= nums.size()){
    ret.push_back(subset);
    return;
  }
  for(int i = idx; i < nums.size(); i++){
    subset.push_back(nums[i]);
    // accept choice
    dfs(ret, subset, nums, i + 1);
    // reject choice
    subset.pop_back();
    
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
As we see for each element in the set, we are deciding to push it or not, the recursive call makes us dfs the search space where such element is included, when the dfs returns the element won't be pushed, since we already analyzed the search space 
where the element is included, now we have to search the state space in which the element is not included.

# Permutations
Given an array nums of distinct integers, return all the possible permutations. You can return the answer in any order.
```cpp
    void dfs(vector<int>& nums, vector<int>& permutation, vector<vector<int>>& ret, vector<bool>& used){
        // end condition
        if(permutation.size() == nums.size()){
            ret.push_back(permutation);
            return;
        }
        // choose an index
        for(int i = 0; i < nums.size(); i++){
            // see if it's already in the permutation
            if(used[i] == true)
                continue;
            // push state
            used[i] = true;
            permutation.push_back(nums[i]);
            dfs(nums, permutation, ret, used);
            // pop state
            used[i] = false;
            permutation.pop_back();
        }
    }

    vector<vector<int>> permute(vector<int>& nums) {
        // track indeces used with a vector
        vector<bool> used(nums.size(), false);
        vector<int> permutation = {};
        vector<vector<int>> ret = {};
        dfs(nums, permutation, ret, used);
        return ret;
    }
```
Computationally a harder problem than subset since $O(n!) > O(2^n)$. The approach i used in this case is tracking, what indeces i pushed in the forming permutations, every time we rescan all vector to search for indeces that are not being used. In this case the choice is pushing nums[i] in a precise order.



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







