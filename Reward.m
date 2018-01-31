function R = Reward(P, sum_p, Pmax, noise)
    punish = log2(abs(sum_p-Pmax));
    R = log2(1+P/noise)-punish;
end