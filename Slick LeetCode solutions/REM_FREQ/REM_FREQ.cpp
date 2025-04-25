class Solution {
public:

    bool check(int* arr){
        int el = -1;
        // controlliamo che tutte le lettere abbiano frequenza uguale 
        for(int i = 0; i < 26 ; i++){
            if(arr[i] != 0){
                if(el != -1 && arr[i] != el){
                    // se almeno una lettera non ha la stessa frequenza
                    // allora check falso
                    return false;
                }
                // settiamo la frequenza fixata
                el = arr[i];
            } 
        }
        // passati i check
        return true;  
    }

    bool equalFrequency(string word) {
        
        int arr[26];
        memset((void*)arr,0,26*sizeof(int));
        // tabella per le frequenze
        for(int i = 0; i < word.size(); i++)
            arr[word[i] - 'a']++;
        

        for(int i = 0; i < 26; i++){
            if(arr[i] != 0){
               // se ha frequenza proviamo a eliminarla e vedere se la stringa è corretta
                arr[i]--;
                if(check(arr)){
                    return true;
                } 
                arr[i]++;
            }
        
        }
        return false;
        
    }
};
