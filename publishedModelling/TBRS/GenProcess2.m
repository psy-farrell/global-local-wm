function opcorrect = GenProcess2(list, cond)
% Executes 1 process, rehearses in the remaining time based on retrieval
% Version 2, assuming experimenter-controlled pace (totalTime = available
% time window)

global E
global C
global P
global M

rate = max(0.1, E.oprate(cond) + randn*P.ratesd);
totalTime = E.opduration(cond)+E.freetime(cond);
opduration = min(-log(1-C.tau)/rate, totalTime);
realFreetime = totalTime-opduration;
%maximum time for operation duration is the time until the next stimulus
%for the next operation is displayed. E.freetime is the mean free time, the
%actual free time depends on what the actual operation duration turns out
%to be after random variation in rate is factored in

%Decay during operation
M.w = M.w * exp(-P.decay * opduration);
     
if ~isempty(M.trace), M = GetTrace(M, P, list, opduration); end  %trace 4 - after decay during operation
  
GenRefresh(realFreetime, list, 1, M.inpos);

opcorrect = realFreetime > 0;
%if time limit is reached by processing duration (so that realFreetime = 0), a time-out error is assumed
