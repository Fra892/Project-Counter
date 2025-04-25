/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode() : val(0), next(nullptr) {}
 *     ListNode(int x) : val(x), next(nullptr) {}
 *     ListNode(int x, ListNode *next) : val(x), next(next) {}
 * };
 */
class Solution {
public:
    void insert_list(ListNode*& head, ListNode* node){
        ListNode** p = &head;
        while(*p){
            p = &(*p)->next;
        }
        node->next = *p;
        *p = node;
    }
    ListNode* addTwoNumbers(ListNode* l1, ListNode* l2) {
        ListNode* NewHead = 0;
        int carry = 0;
        while(l1 || l2 || carry){
            int val1 = (l1)? l1->val: 0;
            int val2 = (l2)? l2->val : 0;
            ListNode* p = new ListNode;
            if(val1 + val2 + carry >= 10){
                p->val = carry + val2 + val1 - 10;
                carry =  1;
               
            } else {
                p->val = carry + val2 + val1;
                carry = 0;
            }
            p->next = nullptr;
            insert_list(NewHead,p);
            l1 = (!l1)? l1: l1->next;
            l2 = (!l2)? l2: l2->next;
        }
        return NewHead;
    }
};
