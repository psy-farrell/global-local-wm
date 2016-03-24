function [response, correct, recalltime] = GenRecall(list, position)


global C
global P
global M

maxtime = 5; 
r = max(0.1, P.recallrate + randn*P.ratesd);  %random variation of rate 
recalltime = min(maxtime, -log(1-C.tau)/r);  %solving the exponential growh function for time after setting strength = tau --> actual encoding time until tau is reached
response = GenRetrieval(position, recalltime); 
response = response(1);
if response > 0, %if the response is not an omission
    M.w = M.w - P.learnasymptote * (M.cue(position,:)' * (M.stim(response,:).*M.wm));  %response suppression
end
correct = response == list(position); %correct in position

if ~isempty(M.trace), M = GetTrace(M, P, list, recalltime); end  %trace during recall