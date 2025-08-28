## Heap (Priority Queue)

A **heap**, also known as a **priority queue**, is a nearly balanced **binary tree** that can be efficiently stored in an array. It has the following properties:

- The nodes are as far **left-aligned** as possible (especially noticeable in the last level of the tree).
- For any given node, the value of the **root** is either **greater than or equal to** (in a max-heap) or **less than or equal to** (in a min-heap) the values of its descendants.

### Types of Heap

- **Max-heap**: For any node, the values in its subtrees are **less than or equal to** its value.  
  → The root of the heap contains the **maximum** value.

- **Min-heap**: For any node, the values in its subtrees are **greater than or equal to** its value.  
  → The root of the heap contains the **minimum** value.
![Max Heap](../Images/heap2.drawio.svg)

Heaps can be implemented with a fixed size or not. Note that the stdlib implementation std::priority_queue has a dynamic length (this kind of heap can be made with pointers, or with dynamic arrays). In an Array-Heap are implemented some recursive formulas to access the sons and the father from a node having index $i$, in paticular: For each index $i$ you can calculate:
- father: `i/2`
- left-son: `2*i`
- right-son: `2*i + 1`

  
This is true if you are implementing a 1-indexed structure, to implement a 0-indexed structure the formulas are slightly different:
- father: `(i - 1)/2`
- left-son: `2*i + 1`
- right-son: `2*i + 2`

  
Here is a possible implementation of a dynamic heap based on vector<int> container.
```cpp
class maxHeap{
    vector<int> Hp;
    int size; // starting size (useful for Heapsorts)
    int last;
public:
    maxHeap(int sz){
        size = sz;
        Hp.resize(sz,0);
        last = 0;
    }
    void push(int el){
        if(last == size){
          size *= 2; // or some grow factor
          Hp.resize(size);
        }
        // resize the heap
        Hp[last++] = el;
        up();
    }
    void up(){
        int i = last - 1;
        while(i > 0 &&  Hp[i] > Hp[(i - 1)/2]){
            swap(Hp[i], Hp[(i - 1)/2]);
            i = (i - 1)/2;
        }
    }

    void down() {
        int i = 0;
        // left aligned just check condition for left son(there are no holes)
        while (2 * i + 1 < last) {
            int new_index;
            if((2 * i + 2) == last)
                new_index = 2*i + 1;
            else
                new_index = (Hp[2 * i + 1] > Hp[2 * i + 2]) ? 2 * i + 1 : 2 * i + 2;
            // no need to swap anymore (right position)
            if(Hp[i] > Hp[new_index])
                break;
            swap(Hp[i], Hp[new_index]);
            i = new_index;
        }
    }

    int pop(){
        if(!last)
            return -1;
        int el =  Hp[0];
        Hp[0] = Hp[--last];
        down();
        return el;
    }
};  

```
Note that we are filling using last++ and --last, every value will be inserted in a certain level from left to right, hence there are no holes in the binary tree, this ensures a nice logarithmic time for up and down functions, since it will never collapse to a linked list. 
This is a zero indexed maxHeap, note that we can print it using a tecinque called BFS, we will study this technique better later on. To try it here's my implementation:
```cpp
void print_heap(){
        cout << "------------- Heap ---------------";
        if(!last)
            return;
        queue<pair<int,int>> q;

        // calculate height
        int max_level = 0;
        while ((1 << max_level) < last) max_level++;

        int level = -1;
        q.push({0,0});
        while(!q.empty()){
            int idx, level_curr, spaces;
            tie(idx, level_curr) = q.front();
            q.pop();
            spaces = (1 << (max_level - level_curr)) - 1;
            if(level_curr != level){
                cout << '\n';
                // Print leading spaces in case new level
                for (int i = 0; i < spaces; ++i) cout << " ";
            }
            level = level_curr;
            cout << Hp[idx] << ' ';
            for (int i = 0; i < spaces*2; ++i) cout << " ";
            if(2*idx + 1 < last)
                q.push({2*idx + 1, level_curr + 1});
            if(2*idx + 2 < last)
                q.push({2*idx + 2 , level_curr + 1});
        }
        cout << "\n----------------------------------\n";
    }

```
## MaxHeaps and MinHeaps
Let's now think of a problem. Given a datastream of integer store the K's Maximum elements. If we are choosing to implement a MaxHeap we are sure that the 
root `Hp[0]` contains the biggest element, but the other k - 1 elements are not sorted in the heap. We can look at the problem from another perspective and invert the logic of the heap. Let's say i use a minheap, i have already k element in the heap and `Hp[0]` is the smallest, what would happen if i added another element such that is smaller than the root?
This element will be pushed to the top and the previous root would be somewhere in the heap. So now i can pop the root to get the k maximum elements:
``` cpp
    // reverse the logic and use a MinHeap instead of a MaxHeap
    // add function currSize() to get the actual length of the Heap in classMinHeap or MaxHeap(if asking for k smallest elements)
    int currSize(){
        return last;
    }

    int main(){
        int x; MinHeap Hp(8); // one more than what we need otherwise can't process k + 1 element
        int K = 7;
        while(cin >> x){
            Hp.push(x);
            if(Hp.currSize() > 7)
                Hp.pop();     
        }
        // store the results
        vector<int> max_k_elements(K,0);
        int i = 0;
        // fill the vector
        while(K--)
            max_k_elements[i++] = Hp.pop();

        // invert since it's asking for the maxiumum
        reverse(max_k_elements.begin(), max_k_elements.end());
        for(auto& el : max_k_elements)
            cout << el << ' ';
        cout << '\n';
        return 0;
    }
```
The standard library implementation (std::priority_queue) can't be initialized with a certain size, but the method are similar to the ones we defined in our implementation.



# Applications

let's now list problems and solutions that are solved with an heap or a priority queue.

## SJF CPU
You are given  n tasks labeled from 0 to n - 1 represented by a 2D integer array tasks, where `tasks[i] = [enqueueTimei, processingTimei]` means that the `task[i]` will be available to process at `enqueueTime[i]` and will take `processingTime[i]` to finish processing.

You have a single-threaded CPU that can process at most one task at a time and will act in the following way:

- If the CPU is idle and there are no available tasks to process, the CPU remains idle.
- If the CPU is idle and there are available tasks, the CPU will choose the one with the shortest processing time. 
- If multiple tasks have the same shortest processing time, it will choose the task with the smallest index.


Once a task is started, the CPU will process the entire task without stopping. The CPU can finish a task then start a new one instantly.
Return the order in which the CPU will process the tasks.

```cpp
vector<int> getOrder(vector<vector<int>>& tasks) {
    auto cmp = [](pair<int, int>a, pair<int,int>b ){
        if(a.second == b.second)
            return a.first > b.first;
        return a.second > b.second;
    };

    priority_queue<pair<int,int>, vector<pair<int,int>>, decltype(cmp)> pq(cmp);

    for(int i = 0; i < tasks.size(); i++)
        tasks[i].push_back(i);

    sort(tasks.begin(), tasks.end(), [](vector<int>a, vector<int>b){
                                    return a[0] < b[0];
                                    });

    vector<int> ret = {};
    int prev_time = tasks[0][0];
    int idx = 0;

    while(idx < tasks.size()){
        //enqueueing
        while(idx < tasks.size() && tasks[idx][0] <= prev_time){
            pq.emplace(tasks[idx][2], tasks[idx][1]);
            idx++;
        }
            // pop elem
        if(pq.empty()){
            prev_time = tasks[idx][0];
            continue;
        }
                
        ret.push_back(pq.top().first);
        prev_time += pq.top().second;
        pq.pop();
    }
            

    while(!pq.empty()){
        ret.push_back(pq.top().first);
        pq.pop();
    }

    return ret; 
}
```









