function [solution, satisfied_clauses] = Simulated_Annealing_no_memoization(clauses, n)
% MAX3SAT_QUBO_APPROXIMATION - Solves a MAX-3SAT problem using the systematic QUBO approximation method.
%
% Inputs:
%    clauses            - m x 3 matrix, where each row represents a clause. Literals
%                         are represented as positive integers (xi) for variables, and
%                         negative integers (-xi) for negated variables.
%    n                  - Number of variables in the MAX-3SAT problem.
%
% Outputs:
%    solution          - A binary vector of length n, representing the assignment to variables.
%    satisfied_clauses - Number of clauses satisfied by the solution.
%
% Functions:
%    plotting          - plot iter-energy
%    memoization       - saving the processed candidates and their energy
%                      - we won't process old candidates 
%    
%
% Example:
%    % Define clauses: (x1 OR NOT x2 OR x3), (NOT x1 OR x2 OR x3), (x1 OR x2 OR x3)
%    clauses = [1, -2, 3; -1, 2, 3; 1, 2, 3];
%    n = 3; % Number of variables
%    [solution, satisfied_clauses] = max3sat_qubo_approximation(clauses, n);

% Initialize QUBO matrix
Q = zeros(n);

% ONLY FOR PLOT
vector = int32([]);


% For each clause, build the QUBO approximation and update the QUBO matrix
for c = 1:size(clauses,1)     % we loop over the number of rows
    clause = clauses(c,:);    % we take the whole row 
    
    % Extract variables and their signs
    vars = abs(clause);       
    signs = clause > 0;       

    % sign is a boolean vector 
    % while vars are the x_vars
    
    % Determine clause type based on the number of negative literals
    num_neg = sum(~signs);    

    switch num_neg
        case 0 % Type 1: (xi OR xj OR xk)
            local_Q = [-1,  1,  1;
                        0, -1,  1;    
                        0,  0, -1];
            % order doesn't matter %
        case 1 % Type 2: (xi OR xj OR NOT xk)
            local_Q = [0,  1,  -1;
                       0,  0,  -1;   
                       0,  0,   1];
            % we exchange literals wlog 
            % we want the not literals at the end of the clause
            neg_indx = find(signs == false);
            if neg_indx ~= 3
                vars([neg_indx,3]) = vars([3, neg_indx]);
            end 
        case 2 % Type 3: (xi OR NOT xj OR NOT xk)
            local_Q = [1, -1, -1;
                       0,  0,  1;    
                       0,  0,  0];
            % we exchange literals wlog 
            % we want the not literals at the end of the clause
            pos_indx = find(signs == true);
            if pos_indx ~= 1
                vars([1,pos_indx]) = vars([pos_indx, 1]);
            end 

        case 3 % Type 4: (NOT xi OR NOT xj OR NOT xk)
            local_Q = [-1,  1,  1;
                        0, -1,  1;    
                        0,  0, -1];
            % order doesn't matter
        otherwise
            error('Invalid clause type');
            % unreachable 
    end
    
    % Map local_Q to global QUBO matrix Q %
    % we know that is a UT matrix so we just need to check
    % the entries for i <= j
    for i = 1 : 3
        for j = i : 3
         vi = vars(i);
         vj = vars(j);
         % we take the entrance for the current clause
         global_entry = local_Q(i,j);
         %  Q has to be upper triangular
         if vj < vi 
             % adding the contribute of the clause to the 
             % global Q matrix
             Q(vj,vi) = Q(vj,vi) + global_entry;
         else 
             Q(vi,vj) = Q(vi,vj) + global_entry;
         end
         end 
    end 
end



% Solve QUBO problem using simulated annealing
% Set parameters for simulated annealing
max_iter = 5000;
initial_temp = 100;
final_temp = 0.1;


% by setting final and intial temp we can retrive the alpha
% with this formula using a geometric progression 

alpha = (final_temp/initial_temp)^(1/max_iter);

% Initialize assignment randomly
current_solution = randi([0,1], n, 1);
current_energy = current_solution' * Q * current_solution;

best_solution = current_solution;
best_energy = current_energy;

temperature = initial_temp;

for iter = max_iter: -1 : 1
    % Generate neighbor by flipping a random bit
    neighbor_solution = current_solution;
    idx = randi(n);

    % flipping the random bit
    neighbor_solution(idx) = 1 - neighbor_solution(idx);
    % energy of the qubo matrix 
    neighbor_energy = neighbor_solution' * Q * neighbor_solution; 

    % Energy gap
    delta_energy = neighbor_energy - current_energy;
    
    % Metrpolis criterion 
    if delta_energy < 0 || rand() < exp(-delta_energy/temperature)
        vector(end+1) = neighbor_energy;
        % we accepted the new energy as current 
        current_solution = neighbor_solution;
        current_energy = neighbor_energy;
        if current_energy < best_energy
            best_solution = current_solution;
            best_energy = current_energy;
        end
    end
    
    % Decrease temperature
    temperature = temperature * alpha;
end

% plotting of the energy 
plot(0:length(vector)-1,vector,'-r');
xlabel('iter');
ylabel('energy');
title('energy evolution');
% this represents the evolution of the simulated annealing

 


% we recall the best solution marked by SA
solution = best_solution;

% Evaluate the number of satisfied clauses
satisfied_clauses = 0;
for c = 1:size(clauses,1)
    clause = clauses(c,:);
    vars = abs(clause);
    signs = clause > 0;
    % selecting the correct part of the assignment for the clause 
    vals = solution(vars);
    clause_satisfied = any(vals == signs'); % we check if the clause is staisfied
    if clause_satisfied
        satisfied_clauses = satisfied_clauses + 1;
    end
end
% print the results %
fprintf('Number of satisfied clauses: %d out of %d no memoization\n', satisfied_clauses, size(clauses,1));
end


