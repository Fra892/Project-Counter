#include <vector>
#include <iostream>
using namespace std;

/* There are n gas stations along a circular route,
 * where the amount of gas at the ith station is gas[i].
 *
 * You have a car with an unlimited gas tank and it costs cost[i]
 * of gas to travel from the ith station to its next (i + 1)th station.
 * You begin the journey with an empty tank at one of the gas stations.
 *
 * Given two integer arrays gas and cost,
 * return the starting gas station's index if you can travel
 * around the circuit once in the clockwise direction, otherwise return -1.
 * If there exists a solution, it is guaranteed to be unique.
 * _______________________________________________________________________
 * SOLUTION: we define the condition to not begin able to continue as
 *           gas[i] < cost[i]. So we'll need to trace back to get more gas.
 *           When we trace back we need to keep track of the needed gas.
 *           Using a variable payload we keep track of the gas we have.
 *           Now we'll use two pointers (indexes) start and end. If we can go
 *           further we increase the end by one and we jump. If we need to trace back
 *           then the start we'll be descreased by one. The one i started with is not good
 *           if start == end(go further) updating the end we did it and we return start.
 *           if start == end updating(back tracking) the start there's there's no way to do that.
 */

int canCompleteCircuit(vector<int>& gas, vector<int>& cost) {
    int size = gas.size();
    vector<int> rem = gas;

    for( int i = 0; i < size; ++i){
        rem[i] -= cost[i];
    }

    int i = 0, start = 0, end = 0,backup = 0;
    for(;;){
        if(rem[i] + backup >= 0){
            backup += rem[i];
            end = (end + 1) % size;
            if( start == end)
                return start;
            i = end;
            continue;
        }
        backup += rem[i];
        start = (start - 1) % size;
        if(start < 0)
            start += size;
        if( start == end)
            return -1;
        i = start;
    }

}

/* DRIVER */
int main(){
    vector<int> gas, cost;
    gas.push_back(1); gas.push_back(2); gas.push_back(3); gas.push_back(4); gas.push_back(5);
    cost.push_back(3); cost.push_back(4);cost.push_back(5);cost.push_back(1);cost.push_back(2);
    cout << canCompleteCircuit(gas,cost);
    return 0;
}


