#include <iostream>
#include <vector>
#include <ctime>

using namespace std;
typedef long long ll;


vector<ll> V;



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


/* RHO POLLARD */
ll rho_pollard(ll N){
    ll c = 1 , T = 2, H = T, abs;
    ll aux[3];
    for(;;){
        T = ( T * T + c) % N;
        H = ( H * H + c) % N;
        H = ( H * H + c) % N;
        abs  = (H - T >= 0 )? H - T : T - H;
        mcd_euclid_ext(abs, N, aux);
        if( aux[0] == 1)
            continue;
        else if( aux[0] == N){
            T = 2;
            H = 2;
            c++;
            continue;
        }
        else
            break;
    }
    return aux[0];
}
/* END RHO POLLARD */

/* MR TEST */
bool millerTest(ll d, ll n) {
    /* find a \in U(n) */
    ll check[3];

    ll a = 2 + rand() % (n - 4);
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
/* END MR TEST */

/* RECURSIVE FACT */
void factorization(ll N){
    if( N == 1){
        return;
    }
    if(isPrime(N,100000)) {
        V.push_back(N);
        return;
    }
    ll left = rho_pollard(N);
    ll right = N / left;
    factorization(left);
    factorization(right);
}
/* END RECURSIVE FACT */

int main() {
    cout << "Insert a number 1 < N < 100000000" << endl;
    srand(time(nullptr));
    ll N;
    do
        cin >> N;
    while (N >= 100000000 || N <= 1);

    /* N has to be odd */
    while(!(N & 1)) {
        V.push_back(2);
        N /= 2;
    }


    factorization(N);

    if (V.size() == 1) {
        cout << "N is prime" << endl;
    } else {
        cout << "N = ";
        for (auto i = V.begin(); i != V.end(); ++i) {
            cout << *i;
            if (i + 1 != V.end())
                cout << " * ";

        }
    }
    return 0;

}

/* Spiegazione Algoritmo */
/* Dato un intero N positivo iniziamo a fare dei test di primalità con un alta precisione, grazie a MR.
 * Se non risulta primo allora si può usare l'algoritmo Rho di Pollard.
 * L'algoritmo Rho di Pollard si basa sull'idea che siccome siamo in un gruppo finito. prima o poi se si manda
 * un input in pasto a un polinomio (possibilmente irriducibile) produrrà un ciclo. Da li in poi siccome si evolve
 * deterministicamente ciclerà per il resto del tempo. Dato un fattore primo p di N e due numeri che si evolvono
 * (uno al doppio della velocità, Floyd detection cycle), abbiamo che in F_p la collisione avverrà prima dell anello Z/NZ.
 * Dire che c'è stato un ciclo o una collisione equivale a dire che |X_j - X_i| \equiv 0 (p) ovvero p \mid |X_j - X_i|.
 * A questo punto si fa il gcd(n,X_j-X_i) e se è diverso da N e da 1 abbiamo trovato un fattore.
 * il ciclo può essere al massimo di lunghezza p risultando in un effettivo miglioramento sul tempo di esecuzione.
 */








