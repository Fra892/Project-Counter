class Solution {
public:
    string removeDuplicateLetters(string s) {
        int n = s.size();
        vector<vector<int>> pos(26);     // Posizioni di ogni lettera
        vector<bool> used(26, false);    // Lettere già usate

        // Memorizza tutte le posizioni di ogni carattere
        for (int i = 0; i < n; i++) {
            pos[s[i] - 'a'].push_back(i);
        }
        // memorizziamo il numero totale di caratteri da inserire
        int numDistinct = 0;
        for (int i = 0; i < 26; i++) {
            if (!pos[i].empty()) numDistinct++;
        }

        string result = "";
        int last_used = -1;
        // finchè ci sono caratteri da inserire
        while ((int)result.size() < numDistinct) {
            // in ordine lessicografico controlliamo tutti i caratteri
            for (int ch = 0; ch < 26; ch++) {
                if (used[ch]) continue;

                // Trova la prima occorrenza rispetto alla mia posizione nella stringa 
                auto it = lower_bound(pos[ch].begin(), pos[ch].end(), last_used + 1);
                // se non trovata passiamo al prossimo carattere
                if (it == pos[ch].end()) continue;

                int idx = *it;

                // Verifica se tutte le altre lettere non usate sono presenti DOPO idx
                bool ok = true;
                // facciamo il check greedy
                for (int c = 0; c < 26; c++) {
                    // se è già stata usata o è la stessa lettera che vogliamo inserire
                    // o non è presente nella stringa continuiamo
                    if (used[c] || c == ch || pos[c].empty()) continue;
                    // non è ancora stessa messa ed è presente (è raggiungibile?)
                    auto it2 = lower_bound(pos[c].begin(), pos[c].end(), idx + 1);
                    // se non è presente allora passiamo al prossimo carattere
                    if (it2 == pos[c].end()) {
                        ok = false;
                        break;
                    }
                }

                if (ok) {
                    // se sono tutte raggiungibili la aggiungiamo
                    result += (char)(ch + 'a');
                    used[ch] = true;
                    last_used = idx;
                    break;
                }
            }
        }

        return result;
    }
};
