%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Main Loop Runner in parallel:
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parallel_run()
% parpool(pref_poolSize)

ts = 4e4; % table size
iter = [ts, 10*ts, 20*ts, 50*ts, 100*ts];

% parfor_progress(5);
 for i=1:5
    fprintf('iteration = %d\n', iter(i));
    WF_RL_1(iter(i));
%     pause(rand);
%     parfor_progress;
 end
%  parfor_progress(0); % Clean up
end
