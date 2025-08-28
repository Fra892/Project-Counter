## Heap (Priority Queue)

A **heap**, also known as a **priority queue**, is a nearly balanced **binary tree** that can be efficiently stored in an array. It has the following properties:

- The nodes are as far **left-aligned** as possible (especially noticeable in the last level of the tree).
- For any given node, the value of the **root** is either **greater than or equal to** (in a max-heap) or **less than or equal to** (in a min-heap) the values of its descendants.

### Types of Heap

- **Max-heap**: For any node, the values in its subtrees are **less than or equal to** its value.  
  → The root of the heap contains the **maximum** value.

- **Min-heap**: For any node, the values in its subtrees are **greater than or equal to** its value.  
  → The root of the heap contains the **minimum** value.
![Max Heap](../Images/heap.drawio.svg)

Heaps usually have a size. Not that the stdlib implementation std::priority_queue has a dynamic length (this kind of heap can be made with pointers). To implement static sized an array it's enough. For each index $i$ you can calculate his father $i/2$ and his sons $2*i$ (left) and $2*i + 1$ right.
This is true if you are implementing a 1-indexed structure, to implement a 0-indexed structure the formulas are slightly different $(i - 1)/2$ for the index of the father and $2*i + 1$, $2*i + 2$ respectfully for left and right child. Here is a possible implementation of a dynamic heap based on vector<int> container.
```cpp
class maxHeap{
    vector<int> Hp;
    int size;
    int last;
public:
    maxHeap(int sz){
        size = sz;
        Hp.resize(sz,0);
        last = 0;
    }
    void push(int el){
        if(last == size){
          size *= 2; // or size += 10;
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
        // left aligned just check condition for left son
        while (2 * i + 1 < last) {
            int new_index = (Hp[2 * i + 1] > Hp[2 * i + 2]) ? 2 * i + 1 : 2 * i + 2;
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
This is a zero indexed maxHeap, note we can print it using a tecinque called BFS, we will study this technique better later on. To try it here's my implementation:
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






