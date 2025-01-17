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
    ListNode* reverseKGroup(ListNode* head, int k) {
        ListNode* next_group;
        ListNode* curr = head;
        ListNode* next;
        ListNode* prec = nullptr;
        ListNode* tail = nullptr;
        ListNode* newhead;
        next_group = curr;

        while(next_group){
            newhead = curr;
            for(int i = 0; i < k; i++){
                if( !next_group && i <= k - 1 ){
                    tail->next = newhead;
                    goto end;
                }
                next_group = next_group->next;
            }

            prec = nullptr;
            while(curr != next_group){
                next = curr->next;
                curr->next = prec;
                prec = curr;
                curr = next;
             }
             if(!tail){
                tail = head;
                head = prec;
             } else {
                tail->next = prec;
                tail = newhead;
             }
        }
        end:
        return head;

    }
};
