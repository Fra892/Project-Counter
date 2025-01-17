#include <iostream>
using namespace std;
/*
 * O     0     | We note that for example the first element moves 2(n-1) times to get to the next
 * |   / |     | Same thing for the 3rd element. This elements are identical mod % N - 1.
 * 0 0   0     | Let's look at the second element. We note that we need a shorter path now.
 * |/    |     | Every time we add 1 from the first element we have to shorten the path by 2.
 * 0     0     | We get a nice formula MAX = 2(n-1), rel= 2a \implies path = 2(n-1)-2a = 2(n-1-a)
 * ____________| If we work mod N - 1, every elements has the relative path as seen before.
 */
int Get_eqclass(int a, int N){
    a = a % (N - 1);
    return 2 * (N - 1 - a);
}

string Digest(string s, int N){
    if(N == 1 || N >= s.size())
        return s;

    string s_ret = s;
    for(int i = 0,k = 0; i < N ; ++i) {
        for (int j = i; j < s.size(); j += Get_eqclass(j, N))
                s_ret[k++] = s[j];
    }

    return s_ret;
}

/* driver */
int main(){
    string S; int NR;
    cin >> S >> NR;
    S = Digest(S,NR);
    cout << S;
}


