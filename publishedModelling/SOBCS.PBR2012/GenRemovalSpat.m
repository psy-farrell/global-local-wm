function GenRemovalSpat(position, removevector, removaltime)
%generic removal function for distractor removal and response suppression
%in the non-verbal weight matrix M.ws

global M
global P

startoverlap = round(size(M.w,2)*(1-M.ov))+1;
M.ws(:, startoverlap:end) = M.w(:, startoverlap:end); %pull over the current state of the overlapping region of weight matrix
t = M.cue(position,:) * M.ws;
e = t * -removevector';

F = fieldnames(M);
if isempty(find(strcmp(F, 'esub1')))  %if no esub1 exists yet, set it to e, and asymptote = 1    
    M.esub1 = e;
    rasy = 1; 
else
     rasy = logist(e/M.esub1); 
end

strength = rasy*(1-exp(-P.removalrate*removaltime));
M.ws = M.ws - strength * M.cue(position,:)'* removevector;
M.w(:, startoverlap:end) = M.ws(:, startoverlap:end); %push over the current state of the overlapping region of weight matrix

