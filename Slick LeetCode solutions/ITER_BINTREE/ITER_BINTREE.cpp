// preorder 
void visit(node* root) {
    if (!root) return;
    stack<node*> s;
    s.push(root);

    while (!s.empty()) {
        node* curr = s.top();
        s.pop();

        cout << curr->val << endl;

        // ordine invertito perchè lo stack inverte
        if (curr->right) s.push(curr->right);
        if (curr->left) s.push(curr->left);
    }
}

// postorder
void visit(node* root) {
    if (!root) return;
    stack<node*> s;
    stack<node*> inv;
    s.push(root);
    // facciamo una preorder
    while (!s.empty()) {
        node* curr = s.top();
        s.pop();
        inv.push(curr);

        // ordine invertito perchè lo stack inverte
        if (curr->right) s.push(curr->right);
        if (curr->left) s.push(curr->left);
    }
    // e invertiamo
    while(!inv.empty()){
        node* nd = inv.top();
        inv.pop();
        cout << nd->val << endl;
    }
}

// inorder
void visit(node* root) {
    if (!root) return;
    stack<node*> s;
    while(root || !s.empty()){
        while(root){
          s.push(root);
          root = root->left;
        }
        root = s.top();
        s.pop();
        cout << root->val << endl;
        root = root->right;
    }
}
