%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Simulation of Power Allocation in dense mmWave network using 
%   Reinforcement Learning; Cooperative Learning (CL) 
%   And it takes the number of Npower as the number of columns of Q-Table
%
% function PA_CL(Npower, bs_count, BS_Max, bs_permutation, NumRealization, saveNum, CL)

%% Initialization
clc;
total = tic;
%% Parameters
Pmin = 0;                                                                                                                                                                                                                                                                                                                                                                           %dBm
Pmax = 6;
Npower = 31;
%% Minimum Rate Requirements for users
% q_ue = 10.0;

%% Q-Learning variables
% Actios
actions = linspace(Pmin, Pmax, Npower);

% States
states = [1,2]; % states = (dMUE , dBS)

% Q-Table
% Q = zeros(size(states,1) , size(actions , 2));
Q_init = ones(1 , Npower) * 0.0;
Q1 = ones(1 , Npower) * inf;
sumQ = ones(1, Npower) * 0.0;
% meanQ = ones(size(states,1) , Npower) * 0.0;

alpha = 0.5; gamma = 0.9; epsilon = 0.1 ; Iterations = 50000;

%% Main Loop
%     fprintf('Loop for %d number of FBS :\t', fbsCount);
%      textprogressbar(sprintf('calculating outputs:'));
    count = 0;
    errorVector = zeros(1,Iterations);
    agents = cell(1,4);
    for i=1:4
        agents{i} = agent(i); % Power Allocation Agent (PA)
    end
   
    extra_time = 0.0;
    for episode = 1:Iterations
%          textprogressbar((episode/Iterations)*100);
        sumQ = sumQ * 0.0;
        for j=1:size(BS_list,2)
            PA = agents{j};
            sumQ = sumQ + PA.Q; 
        end
        if (episode/Iterations)*100 < 80
            % Action selection with epsilon=0.1
            for j=1:size(agents,2)
                PA = agents{j};
                if rand<epsilon
                  size_action = size(actions,2);  
                  index = floor(rand*Npower+1);
                  PA.index = index;
                  PA.P = actions(index);
                else
                    a = tic;
                    if CL == 1 
                        [M, index] = max(sumQ(kk,:));     % CL method
                    else                                    
                        [M, index] = max(PA.Q(kk,:));   %IL method
                    end
                      a1 = toc(a);
                      PA.index = index;
                      PA.P = actions(index);
                end
                agents{i} = PA;
            end
        else
            for j=1:size(agents,2)
                PA = agents{j};
                if CL == 1 
                    [M, index] = max(sumQ(kk,:));     % CL method
                else                                    
                    [M, index] = max(PA.Q(kk,:));   %IL method
                end
                PA.index = index;
                PA.P = actions(index);
                agents{i} = PA;
            end
        end 
% Calculate Reward
    sum_p = 0.;
    for j=1:size(agents,2)
        PA = agents{j};
        sum_p = sum_p + PA.P;
    end
    for j=1:size(agents,2)
        PA = agents{j};
        index = PA.index;
        R = Reward(PA.P, sum_p);
        PA.Q(index) = PA.Q(index) + alpha*(R-PA.Q(index));
        agents{i} = PA;
    end
        % break if convergence: small deviation on q for 1000 consecutive
        errorVector(episode) =  sum(sum(abs(Q1-sumQ)));
        if sum(sum(abs(Q1-sumQ)))<0.001 && sum(sum(sumQ >0))
            if count>1000
%                 episode;  % report last episode
                break % for
            else
                count=count+1; % set counter if deviation of q is small
            end
        else
            Q1=sumQ;
            count=0;  % reset counter when deviation of q from previous q is large
        end
    end
%     Q = sumQ;
    answer.Q = sumQ;
    answer.Error = errorVector;
    answer.FBS = BS_list;
    for j=1:size(BS_list,2)
        c_fue(1,j) = BS_list{1,j}.C_FUE;
        p_fue(1,j) = BS_list{1,j}.P;
    end
    sum_CFUE = 0.0;
    for i=1:size(BS_list,2)
        sum_CFUE = sum_CFUE + BS_list{i}.C_FUE;
    end
    answer.C_FUE = c_fue;
    answer.P_FUE = p_fue;
    answer.sum_CFUE = sum_CFUE;
    answer.episode = episode;
    tt = toc(total);
    answer.time = tt - extra_time;
    answer.q = q_ue;
    QFinal = answer;
    save(sprintf('DATA/Jan30/R_4_q10/pro_%d_%d_%d.mat',Npower, bs_count, saveNum),'QFinal');
%     FBS_out = BS_list;
% end
