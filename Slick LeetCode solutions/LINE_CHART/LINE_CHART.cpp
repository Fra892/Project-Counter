class Solution {
public:
    int minimumLines(vector<vector<int>>& stockPrices) {
        // sort
        sort(stockPrices.begin(),stockPrices.end(),[](vector<int> a, vector<int> b){
            return a[0] < b[0];
        });

  
        // dati due punti troviamo la derivata y1 - y0 / x1 - x0
        // una volta calcolato il coeff. possiamo vedere se altri punti fanno
        // parte della stessa linea se hanno stesso coefficiente 
        int count = 0, count_lines = 1;
        long long x, y, d_dx_num, d_dx_den;
        // caso punto singolo
        if(stockPrices.size() <= 1){
            return 0;
        }
        for(int i = 0; i < stockPrices.size(); i++){
            count++;
            // se nella act_linea c'è più di un punto
            if(count > 1){
                // calcoliamo num e denom del coeff angolare
                long long new_dv_num = (stockPrices[i][1] - y);
                long long new_dv_den = (stockPrices[i][0] - x);
                // se ci sono già due punti vediamo se è uguale
                if(count > 2){
                    if(new_dv_num * d_dx_den == new_dv_den * d_dx_num){
                        count++;
                    } else {
                        // se non è uguale è una nuova linea con 2 punti
                        count = 2;
                        count_lines++;
                    }   
                }
                // salviamoci il nuovo coefficiente angolare della nuova linea
                d_dx_num = new_dv_num;
                d_dx_den = new_dv_den;
            }
            // salvataggio delle coordinate per il coefficiente angolare
            x = stockPrices[i][0]; 
            y = stockPrices[i][1];        
        }
        return count_lines;
        
    }
};

