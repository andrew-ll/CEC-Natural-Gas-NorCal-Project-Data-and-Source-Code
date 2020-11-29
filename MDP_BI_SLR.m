function [Value, Policy, cpu_time] = MDP_BI_SLR
%MDP_BI(P, R, discount, N, h)


% MDP_BI   A function that uses backwards induction to solve finite-horizon
% MDP problems
% Arguments -------------------------------------------------------------
% Let S = number of states, A = number of actions
%   P_t(S_{t+1}xS_txA_t) = transition matrix from time period t to t+1
%              P could be an array with 3 dimensions or 
%              a cell array (1xA), each cell containing a matrix (SxS) possibly sparse
%   R(SxSxA) or (SxA) = reward/cost matrix
%              R could be an array with 3 dimensions (SxSxA) or 
%              a cell array (1xA), each cell containing a sparse matrix (SxS) or
%              a 2D array(SxA) possibly sparse  
%   discount = discount factor, in ]0, 1]
%   N        = number of periods, upper than 0
%   h_T(S_T)     = terminal reward, optional (default [0; 0; ... 0] )
% Evaluation -------------------------------------------------------------
%   V(S,N+1)     = optimal value function
%                  V(:,n) = optimal value function at stage n
%                         with stage in 1, ..., N
%                         V(:,N+1) = value function for terminal stage 
%   policy(S,N)  = optimal policy
%                  policy(:,n) = optimal policy at stage n
%                         with stage in 1, ...,N
%                         policy(:,N) = policy for stage N
%   cpu_time = used CPU time
%--------------------------------------------------------------------------


cpu_time = cputime;

numT = 4;

%discount = input('Please input the discount factor (between 0 and 1): \n') 
discount = 0.95;

numS = 4;

State = zeros(numS,1);

numA = 3;

TerminalValue = zeros(numS,1);
    
Action = zeros(numA,1);

Cost = zeros(numS,numA,numT);

TransitionProb = zeros(numS,numS,numA,numT);

Value = zeros(numS,numT+1); 
Policy = zeros(numS, numT);
tempValue = zeros(numS,numA,numT);

input_Cost = 'SLR_Cost_913_914_NoCGE.xlsx';
input_TranProb = 'SLR_TranProb_946_99.xlsx';

[~,sheet_name_Cost]=xlsfinfo(input_Cost);
for t=1:1:numT
    Cost(:,:,t) = xlsread(input_Cost,sheet_name_Cost{t});
end
TerminalValue = xlsread(input_Cost,sheet_name_Cost{numT+1});
Value(:,numT+1) = TerminalValue;

[~,sheet_name_Prob]=xlsfinfo(input_TranProb);
for t = 1:1:numT
    for a = 1:1:numA
        sheet_index = a+numA*(t-1); %the sheet's names are by time period first, then by action; e.g., time period 1, action, 1, 2, 3; then time period 2, action 1, 2, 3
        TransitionProb(:,:,a,t) = xlsread(input_TranProb,sheet_name_Prob{sheet_index});
        [numRow, numCol] = size(TransitionProb(:,:,a,t)); 
        if (numRow ~= numS | numCol ~= numS) 
         disp('--------------------------------------------------------')
         disp('The transition probability needs to be a square matrix, with the number of rows or columns being the total number of stuates.')
         disp('--------------------------------------------------------')
            return; %stop the program; input data error
        elseif (sum(TransitionProb(:,:,a,t),2)~=1 ) % sum of all the columns in each row
            disp('--------------------------------------------------------')
            disp('The sum of each row in the transition probability needs to be 1.')
            disp('--------------------------------------------------------')
            return; %stop the program; input data error
        end
    end
end


for t = (numT):-1:1 
    for a = 1:numA
        %fprintf('The current time period is %d, and the action is %d \n', t, a);
        
        tempValue(:,a,t) = Cost(:,a,t) + discount * (TransitionProb(:,:,a,t)*Value(:,t+1));
    end
    
    [Value(:,t),Policy(:,t)] = min(tempValue(:,:,t),[],2);
    
end    

cpu_time = cputime - cpu_time;