struct ListNode{
    ListNode* next;
    int val;
};


ListNode *getIntersectionNode(ListNode *headA, ListNode *headB) {
    bool swapped = false;
    ListNode* longest = headA;
    ListNode* shortest = headB;
    while(longest && shortest){
        longest = longest->next;
        shortest = shortest->next;
    }
    // in case: swap longest & shortest
    if(!longest){
        longest = shortest;
        swapped = true;
    }

    while(longest){
        if(swapped)
            headB = headB->next;
        else
            headA = headA->next;
        longest = longest->next;
    }

    while(headA && headB){
        if(headA == headB)
            return headA;
        headA = headA->next;
        headB = headB->next;
    }
    return nullptr;
}

