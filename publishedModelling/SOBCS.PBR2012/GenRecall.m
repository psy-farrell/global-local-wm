function [response, correct, errortype] = GenRecall(list, probedpos)

global C
global M
global P

recalltime = C.rectime;
cuevector = M.cue(M.position,:);
M.wm = cuevector*M.w;
[response, responsevector] = GenLucerecall;  % retrieved item position selected using Luce choice rule

correct = response == list(probedpos); 
errortype = 0; %correct
if correct == 0, errortype = 1; end %order error
if ismember(response, list) == 0, errortype = 2; end  %item error (extralist item from vocabulary)
if response == -3, errortype = 3; end  %intrusion from distractors 
if response == -4, errortype = 4; end  %omission

GenRemoval(M.position, responsevector, recalltime);  %response suppression (except if omission)

M.w = M.w + randn(size(M.w)).*P.nsubo;   