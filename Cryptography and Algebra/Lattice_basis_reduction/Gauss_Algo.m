function [base_1, base_2] = Gauss_Algo(base_1, base_2)
% we start with two big bases that spans the lattice which is
% a subset of Z^{2}. With this algorithm we can reduce the bases 
% to some way smaller basis which can be used as key for lattice-based 
% crypto-system


% initialize variables %
m = -1;
v1 = base_1;
v2 = base_2;

while true 
    norm_v1 = sqrt(sum(v1.*v1));
    norm_v2 = sqrt(sum(v2.*v2));
    if norm_v1 > norm_v2
        swap(v1,v2);
    end
    % projection on the smaller %
    m = dot(v1,v2)/(sum(v1.*v1));

    % round up to the nearest integer
    % if frac_part == 0.5 we round up to the 
    % nearest even number 
    if m - fix(m) == 0.5
        % this means that we round up to the nearest
        % even number 
        if(mod(fix(m),2) == 0)
            m = fix(m);
        elseif(fix(m) > 0) 
            % if it's not even we should go the other way
            % if it's on the positive axis part +1;
            m = fix(m) + 1;
        else
            % is it's on the negative axis part -1
            m = fix(m) - 1;
        end
    else 
        % we couldn't use the round(m) func because 
        % it is not expressive enough
        m = round(m);
    end
    % exit condition
    if m == 0
        break;
    end
    % we reduce v_2
    v2_star = v2 - v1.*m;
    v2 = v2_star;
end 

fprintf("la soluzione è /n");
display(v1,v2);
% time-complexity: O(log(|v1|) + |v2|);

end
