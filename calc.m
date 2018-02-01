function c = calc(PA)
    c = 0.0;
    for i=1:size(PA.P,2)
        c = c + log2(1+PA.P(i)/PA.noise_level(i));
    end
end