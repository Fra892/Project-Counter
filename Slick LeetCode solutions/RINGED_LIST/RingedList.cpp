#include <iostream>
using namespace std;



class RingList {
private:
    struct node {
        int label;
        node *next;
    };
    node *head;
    node *tail;
    bool LIFI; // true = LI ,false = FI

    int pop_ring1(node* q,int ret){
        node *p;
        while( q->next != this->head ) {
            p = q;
            q = q->next;
        }
        ret = q->label;
        this->tail = p;
        p->next = q->next;
        delete q;
        return ret;
    }
    int pop_ring2(node *q, int ret){
        ret = q->label;
        this->head = q->next;
        this->tail->next = this->tail->next->next;
        delete q;
        return ret;
    }

public:

    RingList(){
        head = tail = nullptr;
        LIFI = true;
    }

     void Ring_Mode(string s){
        if (s == "LI" || s == "li" || s == "Li" || s == "lI")
            this->LIFI = true;
        else if( s == "FI" || s == "fi" || s == "Fi" || s == "fI")
            this->LIFI = false;
    }

    void push_ring(int value) {
        node* z = this->head;
        node* p = new node;
        p->label = value;

        if (empty()){
            head = tail = p;
            p->next =  head;
            return;
        }
        while(z->next != head){
            z = z->next;
        }
        z->next = p;
        p->next = head;
        tail = p;
    }

    bool empty(){
        return this->head == nullptr;
    }
    int ring_base(){
        if(empty())
            return 0xFFFFFFF;

        return LIFI ? this->head->label : this->tail->label;
    }
    int ring_top(){
        if(empty())
            return 0xFFFFFFF;

        return LIFI ? this->tail->label : this->head->label;
    }

    int pop_ring(){
        int ret = 0; node *q = this->head;
        if(!q)
            return -1;

        if(q->next == q) {
            ret = q->label;
            this->head = this->tail = nullptr;
            return ret;
        }

        if( this->LIFI )
            return pop_ring1(q,ret);
        else
            return pop_ring2(q,ret);
    }
};

/* DRIVER */
int main(){
  RingList R;
  R.Ring_Mode("LI");

  cout <<"---| QUEUE LIFO MODE TEST |---" <<endl;

  cout <<"______________________________"<<endl;
  cout<<"| TEST 1 (empty?): "<< R.empty()<<"         |"<<endl;
  cout<<"| TEST 2 (push {1,2,3,4})    |"<<endl;
  R.push_ring(1); R.push_ring(2); R.push_ring(3); R.push_ring(4);
  cout<<"| TEST 2 (empty?): "<<R.empty()<<"         |"<<endl;
  cout<<"| TEST 3 (R.top()): "<<R.ring_top()<<"        |"<< endl;
  cout<<"| TEST 4 (R.base()): "<<R.ring_base()<<"       |"<< endl;
  cout<<"| TEST 5 (pop()): "<< R.pop_ring()<< "          |"<<endl;
  cout<<"| TEST 6 (3pop()): "<< R.pop_ring()<<' '<<R.pop_ring()<<' '<<R.pop_ring()<<"     |"<<endl;
  cout<<"| TEST 7 (dealloc?): "<< R.empty()<< "       |"<<endl;
  cout <<"------------------------------"<<endl;
  cout<< endl;
  cout<< endl;
  R.Ring_Mode("FI");
  cout <<"---| QUEUE FIFO MODE TEST |---" <<endl;

  cout <<"______________________________"<<endl;
  cout<<"| TEST 1 (empty?): "<< R.empty()<<"         |"<<endl;
  cout<<"| TEST 2 (push {1,2,3,4})    |"<<endl;
  R.push_ring(1); R.push_ring(2); R.push_ring(3); R.push_ring(4);
  cout<<"| TEST 2 (empty?): "<<R.empty()<<"         |"<<endl;
  cout<<"| TEST 3 (R.top()): "<<R.ring_top()<<"        |"<< endl;
  cout<<"| TEST 4 (R.base()): "<<R.ring_base()<<"       |"<< endl;
  cout<<"| TEST 5 (pop()): "<< R.pop_ring()<< "          |"<<endl;
  cout<<"| TEST 6 (3pop()): "<< R.pop_ring()<<' '<<R.pop_ring()<<' '<<R.pop_ring()<<"     |"<<endl;
  cout<<"| TEST 7 (dealloc?): "<< R.empty()<< "       |"<<endl;
  cout <<"------------------------------"<<endl;

  return 0;
 }
