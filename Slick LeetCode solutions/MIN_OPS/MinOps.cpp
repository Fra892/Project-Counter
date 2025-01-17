#include <vector>
#include <iostream>
#include <algorithm>
using namespace std;


/* Given two sets implemented as vectors, we wanna find the min numbers
 * of deletions such that the smallest number of the first set, divides
 * every second element of the second vector
 *
 * IDEA: We reach this goal when we have that the smallest is indeed divi
 *       ding every element of the second set. A divisor ov every elements
 *       of the second set has to divide the gcd. So we find the gcd
 *       as gcd(a_0,...,a_n)=gcd(gcd(a_0,...,a_n-1),a_n). Using a_0 = 0.
 *       since gcd(0,a_i) = a_i.
 *       Now we sort the vector in a descending fashion. and we pop progressively
 *       until we found en element. when we delete we increase a counter to keep
 *       track of them. If it's empty we didn't found anything so we let ret = -1;
 *       ignoring the counter. An important optimization is that smallst has to be <= gcd.
 *       if it's bigger then all the other number in the sorted array won't divide the gcd.
 *       As a not pure function the vector after the function is in the correct state.
 *       (No need to delete any other element)
 *
 */




int minOperations(vector<int>& nums, vector<int>& numsDivide) {
    int a = 0, counter = 0;

    /* finding the gcd */
    for(int i = 0; i < numsDivide.size(); ++i)
        a  = __gcd(a,numsDivide[i]);

    /* rearraging the vector  */
    sort(nums.begin(),nums.end(),greater<int>());
    /* in the tail there's the smallest */

    /* Now we pop until the tail satisfies cond */
    while(!nums.empty()){
        int smallst = nums.back();

        if( smallst > a) {
            nums.clear(); // the vector is in the correct state ( empty )
            break;
        }

        if(!(a % smallst))
            return counter;
        /* pop the element and incrementing the counter */
        nums.pop_back();
        counter++;

    }
    return -1;
}

int main(){
    int n,N_1,N_2;
    cout << " _________ MIN OPS DRIVER _________  "<< endl;
    cout << "|_________| <----------> |_________| "<<endl;
    cout << "     |                        |      "<<endl;
    cout<<  "   size s                   size t   "<<endl<<endl;
    cout << " _________  INSERT SIZES  _________  "<<endl;
    cout << " sizeof(VecDivs)    sizeof(VecToDiv) "<<endl;
    do{
        cin>>N_1>>N_2;
    }while(N_1 <= 0 && N_2 <=0);
    vector<int>nums, numsDivide;
    cout << endl << endl;
    cout << " _________   VEC FILLER   _________ "<<endl;
    cout << "| INSERT          "<<N_1<< "          ELEMS |"<<endl;
    for(int i = 0; i < N_1; ++i){
        cin >> n;
        nums.push_back(n);
    }
    cout << "| VecDivs                   Filled |"<<endl;
    cout << "| INSERT          "<<N_2<< "          ELEMS |"<<endl;
    for(int i = 0; i < N_2; ++i){
        cin >> n;
        numsDivide.push_back(n);
    }
    cout << "| VecToDiv                  Filled |"<<endl;
    cout << " __________________________________"<<endl;
    cout << "           MINOPS: " << minOperations(nums,numsDivide) <<endl;
    return 0;

}
