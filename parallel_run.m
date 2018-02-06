%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Main Loop Runner in parallel:
%   In this case single thread is faster than parallel, so no parallel
%   running
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parallel_run()
% parpool(pref_poolSize)

ts = 7^4; % table size
iter = [ts, 10*ts, 20*ts, 40*ts, 50*ts, 100*ts];

% parfor_progress(5);
 for i=1:6
    fprintf('iteration = %d\n', iter(i));
    WF_RL_single_state(iter(i));
%     pause(rand);
%     parfor_progress;
 end
%  parfor_progress(0); % Clean up
end
