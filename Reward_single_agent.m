function R = Reward_single_agent(PA, Pmax)
    punish = log2(abs(sum(PA.P)-Pmax));
    R = 0;
    for i=1:size(PA.P,2)
        p = PA.P(i);
        n = PA.noise_level(i);
        R = R + log2(1+p/n);
    end
    R = R - punish;     
end