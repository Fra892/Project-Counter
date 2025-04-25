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
    ListNode* mergeTwoLists(ListNode* list1, ListNode* list2) {
        ListNode **ins = &list1; 
        while(list2){
            if(!(*ins) || list2->val < (*ins)->val ){
                ListNode *p = new ListNode(list2->val);
                p->next = *ins;
                *ins = p;
                list2 = list2->next;
            }
            ins = &(*ins)->next;
        }
        return list1;  
    }
};
