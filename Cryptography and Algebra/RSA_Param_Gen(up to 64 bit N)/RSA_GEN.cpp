#include <iostream>
#include <random>
// In base al sistema operativo scommentare la riga corrispondente
// #define LINUX
// #define WINDOWS
typedef long long ll;
using namespace std;

random_device rd;
mt19937 gen(rd());
uniform_int_distribution<long long>distp(2,3037000499);

/* EUCLID EXT */

void mcd_euclid_ext(ll a, ll b, ll* res)
{
    ll swap[3];/* swap aux vector*/
    ll mat[2][2]={{1,0},{0,1}};/*aux matrix*/
    while(b){
        /* update matrix */
        swap[0]=mat[0][0]; swap[1]=mat[0][1];
        mat[0][0]=mat[1][0]+(a/b)*mat[0][0];
        mat[0][1]=mat[1][1]+(a/b)*mat[0][1];
        mat[1][0]=swap[0]; mat[1][1]=swap[1];
        /* finish update*/
        /* classic ecl algo*/
        swap[2] = b;
        b = a % b;
        a = swap[2];
        /* classic ecl algo*/
    }
    bool sign=(mat[1][1]*mat[0][0]-mat[1][0]*mat[0][1]< 0);
    /* chossing c given by second row solutions*/
    res[0]=a;
    res[1]=(sign)?-mat[1][1]:mat[1][1];
    res[2]=(sign)?mat[1][0]:-mat[1][0];
    /* returining vars*/
}

/* END EUCLID EXT */

/* MOD EXP */

ll power( ll x, unsigned long y, ll p){
    /* we use unsigned to do shift */
    ll res = 1;
    x = x % p;
    while (y > 0) {
        if (y & 1)
            res = (res * x) % p;
        y = y >> 1;
        x = (x * x) % p;
    }
    return res;
}

/* END MOD EXP */

/* MILLER TEST */

bool millerTest(ll d, ll n) {
    /* find a \in U(n) */
    ll check[3];

    ll a = 2 + distp(gen) % (n - 4);
    mcd_euclid_ext(a,n,check);

    if(check[0] != 1)
        return false;

    ll x = power(a, d, n);

    /* 1st condition */
    if (x == 1 || x == n-1)
        return true;

    /* 2nd condition */
    while (d != n - 1){
        x = (x * x) % n;
        d *= 2;
        if (x == n - 1) return true;
    }
    return false;
}

bool isPrime(ll n, int k) {
    /* check neg */
    if (n <= 1 || n == 4) return false;
    /* check basic primes */
    if (n <= 3) return true;

    /* finding d */
    ll d = n - 1;
    while (d % 2 == 0)
        d /= 2;

    for(int i = 0; i < k; i++){
        if (!millerTest(d, n))
            return false;
    }
    return true;
}

/* END MILLER TEST */

int main(){
begin:
    #ifdef LINUX
        cout<<"\033[2J\033[1;1H";
    #elif defined WINDOWS
	    system("cls");
    #endif

    int precise;
    cout<<"------- RSA Parameters Generator -------"<<endl;
    cout << "-insert k (high and positive)"<<endl;

    /* controls on k */
    for(;;) {
        cin >> precise;
        if( precise >= 10)
            break;
    }
    /* prime generator */
    ll p,q;
    do{
        p = distp(gen);
    }
    while(!isPrime(p,precise));

    do{
	q = distp(gen);
    }
    while(!isPrime(q,precise));

    /* p,q are primes */


    /* RSA algorithm */
    ll phi_n = (p-1)*(q-1);
    ll e = 32769;
    /* using F_i where i >= 4 since it's secure */
    ll aux[3];
    do {
        e = (e - 1) * 2;
        e++;
        mcd_euclid_ext(e, phi_n, aux);
    }
    while(aux[0] != 1);

    ll d = aux[1] % phi_n;

    if( d < 0){
        d += phi_n;
    }


    cout << "N: " << p * q << endl;
    cout << "e: " << e << endl;
    cout << "d: " << d << endl;
    cout << "Do u want to keep this config (Y/N)?" << endl;
    char yn;

choice:
    cin>> yn;
    if(yn == 'n' || yn == 'N'){
        goto begin;
    }
    if(yn != 'y' && yn !='Y'){
        goto choice;
    }
    return 0;
}
