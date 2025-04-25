/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode() : val(0), left(nullptr), right(nullptr) {}
 *     TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 *     TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 * };
 */
class Solution {
public:
    // struttura dati per segnarsi il livello
    // ottimizzazione: usare map
    struct node_lvl{
        TreeNode* node;
        int level;
        node_lvl(TreeNode* n,int lvl){
            node = n;
            level = lvl; 
        }
    };

    vector<vector<int>> levelOrder(TreeNode* root) {
        vector<vector<int>> ret;
        // queue per bfs
        queue<node_lvl>q;
        vector<int> level;
        // se null ritorno {}
        if(!root){
            return ret;
        }
        // root setup
        q.push(node_lvl(root,0));
        int global_lvl = 0;

        while(!q.empty()){
            // prendiamo in stile bfs i nodi
            node_lvl root = q.front();
            q.pop();
            TreeNode* act_root = root.node;
            int lvl = root.level;
            // se il livello è più basso, vuol dire che abbiamo
            // finito il livello precedente
            if(global_lvl != lvl){
                ret.push_back(level);
                level.clear();
            }
            global_lvl = lvl;
            // da sinistra 
            if(act_root->left){
                q.push(node_lvl(act_root->left,lvl+1));
            }
            // a destra
            if(act_root->right){
                q.push(node_lvl(act_root->right,lvl+1));
            }
            // salviamo quello attuale
            level.push_back(root.node->val);
        }
        // non abbiamo ancora messo l'ultimo 
        if (!level.empty()) {
            ret.push_back(level);  
        }
        return ret;
        
    }

};
