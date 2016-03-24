function [response, duration] = GenRetrieval(position, duration)

global M
global C
global P


M.wm = M.cue(position,:)*M.w;
M.wm = M.wm + randn(1,C.un)*max(0.0001, P.noisefactor);  
response = find(M.wm == max(M.wm));
if max(M.wm) < P.threshold, 
    response = 0; 
end
M.w = M.w * exp(-P.decay*duration);  % Decay during retrieval

