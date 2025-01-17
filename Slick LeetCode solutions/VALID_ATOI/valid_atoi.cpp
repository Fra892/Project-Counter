class Solution {
public:
    bool isNumber(string s) {
        bool decimal = false, exp = false;
        int i = 0; bool exc = false;
    number:
        if(s[i] == '+'|| s[i] == '-')
            exc = true;
        else if(s[i] == '.'){
            if(decimal)
               return false;
            exc = true;
            decimal = true;
        }
        else if(s[i] < '0'|| s[i] > '9')
            return false;

        ++i;
        for(; i < s.size(); ++i){
            if(s[i] == '.' ){
                if(decimal)
                    return false;
                decimal = true;
                continue;
            }
            if(s[i] == 'e' || s[i] == 'E'){
                if(exp || exc)
                    return false;
                exp = true;
                decimal = true;
                ++i;
                goto number;
            }
            if(s[i] < '0'|| s[i] > '9')
                return false;

            exc = false;
        }
        return !exc;


    }

};
