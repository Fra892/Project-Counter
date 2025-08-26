# Complete Searches
When solving a problem, one brute-force approach is to enumerate all possible solutions and select the best among them. This approach, known as complete search, is sometimes the only viable method — especially in problems that ask for all permutations, combinations, or subsets. While complete search generally has exponential time complexity, it's a valid approach when the input size is small or when time constraints are relaxed.

Let’s consider the example of generating all subsets of a set S. Each subset is defined by a sequence of binary choices: for each element, we decide whether to include it or not. This process naturally forms a decision tree, where each node represents a partial solution, and each level corresponds to a choice for one element.

In more complex problems, each step may offer multiple choices, and the decision process forms a state space tree or search graph. To explore this graph, we typically use depth-first search (DFS) because it aligns well with recursive backtracking.

Tha aim of complete searches is to explore all the solutions to the problems to solve the problem. Every problem could be resolved with complete searches since we are analyzing the whole state space. As said this come with a tradeoff:
- Time-Complexity The algorithm has exponential time-complexity since it's analyzing all possible states.
- Memory-Complexity If implmented with recursion, the recursive calls allocated on the stack can cause stack overflow even for small instances with a moderate number of branches in the state space.
  
## Subsets
Declaration: Given an array of integers nums representing a set, return an array containing all possible subset of the set nums. Order is not important.
```cpp
      void dfs(vector<vector<int>>& ret, vector<int>& subset, vector<int>& nums, int idx){
        // process subset 
        ret.push_back(subset);
        for(int i = idx; i < nums.size(); i++){
            subset.push_back(nums[i]);
            // accept choice
            dfs(ret, subset, nums, i + 1);
            // reject choice
            subset.pop_back();
        }
    }

    vector<vector<int>> subsets(vector<int>& nums){
        vector<vector<int>> ret;
        vector<int> subset;
        int idx = 0;
        dfs(ret, subset, nums, idx);
        return ret;
    }
```
As we see for each element in the set, we are deciding to push it or not, the recursive call makes us dfs the search space where such element is included, when the dfs returns the element won't be pushed, since we already analyzed the search space 
where the element is included, now we have to search the state space in which the element is not included.

## Permutations
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

## Unique Subsets and Permutation
Consider a set $s$  that it cointains duplicates (exmp: $(0,1,1,2,2)$), in this we'll find repeated permutations and subsets, what if i want to find the unique permutations or subsets of such set.  

```cpp
    void dfs(vector<int>& nums, vector<int>& permutation, vector<vector<int>>& ret, vector<bool>& used){
        if(nums.size() == permutation.size()){
            ret.push_back(permutation);
            return;
        }
        int prev_el = 11; // -10 <= nums[i] <= 10 (if no constraint use INF_MIN) 
        for(int i = 0; i < nums.size(); i++){
            if(used[i] || prev_el == nums[i])
                continue;
            used[i] = true;
            permutation.push_back(nums[i]);
            dfs(nums, permutation, ret, used);
            permutation.pop_back();
            // we can have equal combination since it's the same as the one we last pushed
            prev_el = nums[i];
            used[i] = false;
        }
    }

    vector<vector<int>> permuteUnique(vector<int>& nums) {
        sort(nums.begin(), nums.end());
        vector<bool> used(nums.size(), false);
        vector<int> permutation = {};
        vector<vector<int>> ret = {};
        dfs(nums, permutation, ret, used);
        return ret; 
    }
```
The code above finds all the unique permutations of an array nums, in this cases the common strategy is to sort the array and ignore identical elements that come after the first fo those that we push, beacause it leads to overlapping permutations or subsets. The condition could be rewrote as 
```cpp
// inside for
if(i > 0 && nums[i] == nums[i - 1])
  continue;
// push state
// pop state
```
The Unique subset code behaves in the same way 
```cpp
    void dfs(auto& ret, auto& subset, auto& nums, int idx){
        ret.push_back(subset);
        for(int i = idx; i < nums.size(); i++){
            if(i > idx  && nums[i] == nums[i - 1])
                continue;
            subset.push_back(nums[i]);
            // accept choice
            dfs(ret, subset, nums, i + 1);
            // reject choice
            subset.pop_back();
        }
    }

    vector<vector<int>> subsetsUnique(vector<int>& nums){
        sort(nums.begin(), nums.end());
        vector<vector<int>> ret;
        vector<int> subset;
        int idx = 0;
        dfs(ret, subset, nums, idx);
        return ret;
    }
```
Notice that the condition for pruning the search space with duplicates, depends on where we start to iterate on choices. nums[i - 1] == nums[i] indicates that we already analyzed the subsets with nums[i] in that position.

## Combinations
Let's now enumerate all the combinations in [1,...,n] of k elements. 
```cpp
    void dfs(int n, int k, vector<vector<int>>& ret, vector<int>& combination, int numb){
        if(combination.size() == k){
            ret.push_back(combination);
            return;
        }
        for(int i = numb; i <= n; i++){
            // backtracking
            if(k - combination.size() > n - i + 1)
                break;
            combination.push_back(i);
            dfs(n, k, ret, combination, i + 1);
            combination.pop_back();
        }

    }
    vector<vector<int>> combine(int n, int k) {
        vector<vector<int>> ret = {};
        vector<int> combination = {};
        dfs(n, k, ret, combination, 1);
        return ret;
    }
```
Notice that if k - combination.size() is the number of element to push in the combination to reach k, while n - i + 1 it's the amount of element i can push in the combination. Let's take $n = 7$ and $k = 4$, let's position ourself in this state space $S = \{1\}$, $i = 6$, in this configuration if i push all elements remaining to push $S = \{1,6,7\}$ which is not enough to reach k. So it's better to not compute all of those possibilities since we know that those branches can't lead to a possible solution. This technique is called backtracking(pruning), we'll formally introduce it in the next chapter just keep in mind that even if it doesn't theoretically reduce the time complexity, in practice reduces the number of branches generated during the state space search. This can reduce the runtime of an algorithm by multiple orders of magnitude.

## Letter Combinations of a Phone Number
Given a string containing digits from 2-9 inclusive, return all possible letter combinations that the number could represent. Return the answer in any order.
```cpp
    void dfs(auto& ret, string& digits, auto& mp, string& tmp, int idx){
        if(idx >= digits.size()){
            ret.push_back(tmp);
            return;
        }
        for(char a = mp[digits[idx]]; a < mp[(char)(digits[idx] + 1)]; a = (char)(a + 1)){
            tmp += a;
            dfs(ret, digits, mp, tmp, idx + 1);
            tmp.pop_back();
        }
    }

    vector<string> letterCombinations(string digits) {
        if(!digits.size())
            return {};
        unordered_map<char,char> mp = {{'2','a'},{'3','d'},{'4','g'},{'5','j'},{'6','m'},
                                      {'7','p'},{'8','t'},{'9','w'},{':','{'}};
        vector<string> ret;
        string tmp = "";
        dfs(ret,digits,mp,tmp,0);
        return ret;
        
    }
```
This problem is slightly different from typical recursive backtracking problems involving permutations or subsets. Here, the state space isn't generated by making decisions based on the input container (like choosing elements from a set or array), but rather by following a **mapping from digits to characters** (like a telephone keypad).

Each digit from `2` to `9` corresponds to a fixed set of letters. For example:
- `2` → `abc`
- `3` → `def`
- `4` → `ghi`
- ...

The recursive process explores all possible strings that can be formed by picking **one letter per digit**, in the order they appear.

## Other Implementations
It is possible to generate subsets using bit masks, let's say n is the length of the set by doing
```cpp
for(int i = 0; i < 1<<n; i++){
// generate subsets
}
```
we can generate all subsets of the set, this means that with $n = 3$, i = 101 -> (nums[2],nums[0]).
```cpp
    vector<vector<int>> subsets(vector<int>& nums) {
        int size = nums.size();
        vector<int> sol;
        vector<vector<int>> ret;
        for(int i = 0; i < (1U << size); i++){
            sol = {};
            for(int b = 0; b < size; b++){
                if(i & (1U << b))
                    sol.push_back(nums[b]);
                
            }
            ret.push_back(sol);
        }
        return ret;
    }
```
This is the iterative version using bitmasks instead of recursion.
We can check also check uniqueness of subsets with bitmasks:
```cpp
    vector<vector<int>> subsetsWithDup(vector<int>& nums) {
        int n = nums.size();
        vector<vector<int>> ret;
        vector<int> sol;
        sort(nums.begin(), nums.end());
        for(int i = 0; i < (1U << n); i++){
            sol = {};
            bool skip_subset = false;
            for(int b = 0; b < n; b++){
                // not included 
                if(!(i & (1U << b)))
                    continue;
                if(b > 0 && nums[b] == nums[b - 1] && !(i &(1U << b - 1))){
                    skip_subset = true;
                    break;
                }
                sol.push_back(nums[b]);
            }
            if(!skip_subset)
                ret.push_back(sol);
        }
        return ret;
    }
```
The logic is similar but slightly different: if the elements are equal and the previous element is not included it means 
that it is a duplicate, since the old bitmasks already processed all the branching subsets.

Of course the array(set) can't be too long, with an int we have 32 bit usually (use certified types like int_32t to be sure it's 32 bits), this means that the set cannot have more than 32 elements.

Let's end the chapter with another possible implementation to compute permutations:
```cpp
    vector<vector<int>> permute(vector<int>& nums) {
        int n = nums.size();
        vector<int> permutation;
        for(int i = 0; i < n; i++){
            permutation.push_back(i);
        }
        vector<vector<int>> ret;
        vector<int> subset;
        do{
            for(auto &el : permutation)
                subset.push_back(nums[el]);
            ret.push_back(subset);
            subset.clear();
        }while(next_permutation(permutation.begin(), permutation.end()));
        return ret;   
    }
```
The function next_permutation computes the next lexicographic smaller permutation, and it explore every permutation if and only if the starting permutation is the smallest of all (lexicographically).
In the code showed above we would like to compute every permutation, counting duplicates, so it suffices to permute the indices. Start with the identity permutation and then iterate using next_permutation.
If we don't want duplicates, it's surprisingly, easier:
```cpp
    vector<vector<int>> permuteUnique(vector<int>& nums) {
        int n = nums.size();
        sort(nums.begin(), nums.end());
        vector<int> permutation;
        for(int i = 0; i < n; i++)
            permutation.push_back(nums[i]);
        
        vector<vector<int>> ret;
        do{
            ret.push_back(permutation);
        }while(next_permutation(permutation.begin(), permutation.end()));
        return ret;
        
    }
```
Start with the lexicographically smaller permutation of values and then iterate. To find the starting permutation you just need to sort the vector.






