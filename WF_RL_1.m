%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Simulation of Power Allocation in multichannel communication system 
%   Reinforcement Learning; Cooperative Learning (CL) 
%   Solving water-filling with RL
%
%% Initialization
clc;
clear;
total = tic;
%% Parameters
Pmin = 0;                                                                                                                                                                                                                                                                                                                                                                           %dBm
Pmax = 6;
Npower = 6;
%% Minimum Rate Requirements for users
% q_ue = 10.0;

%% Q-Learning variables
% Actios
action_range = linspace(Pmin, Pmax, Npower);

actions = allcomb(action_range, action_range, action_range, action_range);
% States
states = allcomb(0:1, 0:1, 0:1, 0:1);

% Q-Table
% Q = zeros(size(states,1) , size(actions , 2));
Q_init = ones(size(states,1) , Npower^4) * 0.0;
Q1 = ones(size(states,1) , Npower^4) * inf;
sumQ = ones(size(states,1), Npower^4) * 0.0;
% meanQ = ones(size(states,1) , Npower) * 0.0;

alpha = 0.5; gamma = 0.9; epsilon = 0.1 ; Iterations = 2e5;
CL = 0;
%% Main Loop
%     fprintf('Loop for %d number of FBS :\t', fbsCount);
%      textprogressbar(sprintf('calculating outputs:'));
    count = 0;
    errorVector = zeros(1,Iterations);
    agents = cell(1,1);
    agents{1} = agent_4s(1,[1.0, 2.0, 5.0, 3.0]);
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
%                     a = tic;
%                     for kk = 1:size(states,1)
%                         if states(kk,:) == PA.state
%                             break;
%                         end
%                     end
                    kk = PA.S_index;% = kk;
                    if CL == 1 
                        [M, index] = max(sumQ(kk,:));     % CL method
                    else                                    
                        [M, index] = max(PA.Q(kk,:));   %IL method
                    end
                      PA.P_index = index;
                      PA.P = actions(index,:);
                end
                agents{j} = PA;
            end
        else
            for j=1:size(agents,2)
                PA = agents{j};
%                 for kk = 1:size(states,1)
%                     if states(kk,:) == PA.state
%                         break;
%                     end
%                 end
                kk = PA.S_index;% = kk;
                if CL == 1 
                    [M, index] = max(sumQ(kk,:));     % CL method
                else                                    
                    [M, index] = max(PA.Q(kk,:));   %IL method
                end
                PA.P_index = index;
                PA.P = actions(index,:);
                agents{j} = PA;
            end
        end 

% Update the state        
    for i=1:size(agents,2)
        PA = agents{i};
        next_state = zeros(1,4);
        for j=1:size(PA.P,2)
            if PA.P(j)>PA.noise_level(j)
                next_state(j) = 1;
            else
                next_state(j) = 0;
            end
        end
        for kk = 1:size(states,1)
            if states(kk,:) == next_state
                break;
            end
        end
        PA.next_S_index = kk;
        agents{i} = PA;
    end
    
    % Calculate Reward
    for j=1:size(agents,2)
        PA = agents{j};
        qMax=max(PA.Q,[],2);
        R = Reward_single_agent(PA,Pmax);
        state = PA.S_index;
        act = PA.P_index;
        nstate = PA.next_S_index;
        dd = PA.Q(state,act) + alpha*(R+gamma*qMax(nstate)-PA.Q(state,act));
        if isnan(dd)
            sprintf('here!');
        end
        PA.Q(state,act) = dd;
        PA.S_index = nstate;
        agents{j} = PA;
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
    answer.agents = agents;
    answer.episode = episode;
    tt = toc(total);
    answer.time = tt - extra_time;
    QFinal = answer;
    save(sprintf('DATA/WF_RL/pro_%d_%d.mat',Npower,Iterations),'QFinal');
%     FBS_out = BS_list;
% end
