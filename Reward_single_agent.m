function R = Reward_single_agent(PA, Pmax)
%     punish = 0;
    punish = abs(sum(PA.P)-Pmax);
    
    if dd>0
        punish = log2(dd);
    end
    
    R = 0;
    for i=1:size(PA.P,2)
        p = PA.P(i);
        n = PA.noise_level(i);
        R = R + 1+p/n;
    end
    R = R - punish;
    if R==Inf
        sprintf('here');
    end
    R = R /(7.0); % normalized reward
end