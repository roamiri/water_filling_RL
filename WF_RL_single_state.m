%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Simulation of Power Allocation in multichannel communication system 
%   Reinforcement Learning; Cooperative Learning (CL) 
%   Solving water-filling with RL
%
%% Initialization
function WF_RL_single_state(Iterations)
clc;
total = tic;
%% Parameters
Pmin = 0;                                                                                                                                                                                                                                                                                                                                                                           %dBm
Pmax = 6;
Npower = 7;
%% Minimum Rate Requirements for users
% q_ue = 10.0;

%% Q-Learning variables
% Actios
action_range = linspace(Pmin, Pmax, Npower);

actions = allcomb(action_range, action_range, action_range, action_range);

% Q-Table
% Q = zeros(size(states,1) , size(actions , 2));
Q_init = ones(1 , Npower^4) * 0.0;
Q1 = ones(1 , Npower^4) * inf;
sumQ = ones(1, Npower^4) * 0.0;

alpha = 0.5; gamma = 0.9; epsilon = 0.1 ; %Iterations = 3.8e6;
CL = 0;
%% Main Loop
    count = 0;
    errorVector = zeros(1,Iterations);
    agents = cell(1,1);
    agents{1} = agent_1s(1,[1.0, 2.0, 5.0, 3.0]);
    for i=1:size(agents,2)
        PA = agents{i};
        PA = PA.setQTable(Q_init);
        agents{i} = PA;
    end
   
    extra_time = 0.0;
    textprogressbar(sprintf('calculating outputs:'));
    for episode = 1:Iterations
        textprogressbar((episode/Iterations)*100);
        sumQ = sumQ * 0.0;
        for j=1:size(agents,2)
            PA = agents{j};
            sumQ = sumQ + PA.Q; 
        end
        if (episode/Iterations)*100 < 80
            % Action selection with epsilon=0.1
            for j=1:size(agents,2)
                PA = agents{j};
                if rand<epsilon
%                   size_action = size(actions,2);
                  index = floor(rand*size(actions,1)+1);
                  PA.P_index = index;
                  PA.P = actions(index,:);
                else
                    kk=1;
                    if CL == 1 
                        [M, index] = max(sumQ(kk,:));     % CL method
                    else                                    
                        [M, index] = max(PA.Q(kk,:));   %IL method
                    end
                      PA.P_index = index;
                      PA.P = actions(index,:);
                end
                PA.C_profile = [PA.C_profile calc(PA)];
                agents{j} = PA;
            end
        else
            for j=1:size(agents,2)
                PA = agents{j};
                kk = 1;
                if CL == 1 
                    [M, index] = max(sumQ(kk,:));     % CL method
                else                                    
                    [M, index] = max(PA.Q(kk,:));   %IL method
                end
                PA.P_index = index;
                PA.P = actions(index,:);
                PA.C_profile = [PA.C_profile calc(PA)];
                agents{j} = PA;
            end
        end 

    
    % Calculate Reward
    for j=1:size(agents,2)
        PA = agents{j};
        qMax=max(PA.Q,[],2);
        R = Reward_single_agent(PA,Pmax);
        act = PA.P_index;
        dd = PA.Q(1,act) + alpha*(R-PA.Q(1,act));
        if isnan(dd)
            sprintf('here!');
        end
        PA.Q(1,act) = dd;
        agents{j} = PA;
    end
    % break if convergence: small deviation on q for 1000 consecutive
    errorVector(episode) =  sum(sum(abs(Q1-sumQ)));
    %%
    % Stoping point
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
    answer.agents = agents;
    answer.episode = episode;
    tt = toc(total);
    answer.time = tt;
    QFinal = answer;
    save(sprintf('DATA/1s/pro_%1.1fe6.mat',Iterations/1e5),'QFinal');
 end
