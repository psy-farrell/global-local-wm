function GenProcess(list, od, ot)
% Executes 1 process, rehearses in the remaining time based on retrieval

global E
global C
global P
global M

rate = max(0.1, E.oprate(od) + randn*P.ratesd);
opduration = -log(1-C.tau)/rate;  
%there is no maximum time - operation continues until it is finished, freetime is given afterwards independent of operation duration, as in Portrat et al. experiment!

%Decay during operation
M.w = M.w * exp(-P.decay * opduration);
     
if ~isempty(M.trace), M = GetTrace(M, P, list, opduration); end  %trace 4 - after decay during operation
  
%Rehearsal (including decay of non-rehearsed items in the meantime)
GenRefresh(E.freetime(ot), list, 1, M.inpos);
