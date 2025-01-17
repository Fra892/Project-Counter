#include <iostream>

using namespace std;

class Trie {
    struct node{
        node* pointers[26];
        string str;
        bool isleaf;
        node(){
            for(int i = 0; i < 26;++i)
                pointers[i] = nullptr;
            isleaf = false;
        }
    };node *root;

    void c_insert(node* scan,string word) {
        int i = 0; int next_pointer;
        while (word[i] != '\0') {
            next_pointer = word[i] - 'a';
            if (!scan->pointers[next_pointer]) {
                // map new path
                scan->pointers[next_pointer] = new node;
                scan->pointers[next_pointer]->str = word.substr(0, i + 1);
            }
            // move to new path
            scan = scan->pointers[next_pointer];
            ++i;
        }
        // if we finished we mark as leaf
        scan->isleaf = true;
    }

public:
    // creating root tab with empty string
    Trie() {
        root = new node;
        root->str  = "";
    }

    void insert( string word){
        c_insert(this->root,word);
    }

    bool search( string word){
        node* scan = root;
        int i = 0; int next_pointer;

        while(word[i] != '\0'){
            next_pointer = word[i] - 'a';
            if(!scan->pointers[next_pointer])
                return false;
            ++i;
            scan = scan->pointers[next_pointer];
        }
        return scan->isleaf;
    }

    bool startsWith(string word){
        node* scan = root;
        int i = 0; int next_pointer;
        while(word[i] == '\0'){
            next_pointer = word[i] - 'a';
            if(!scan->pointers[next_pointer])
                return false;
            ++i;
            scan = scan->pointers[next_pointer];
        }
        return true;
    }
};

// DRIVER //
int main(){
    Trie trie;
    trie.insert("apple");
    cout << trie.search("apple") << endl;
    cout << trie.startsWith("app")<< endl;
    return 0;
}
