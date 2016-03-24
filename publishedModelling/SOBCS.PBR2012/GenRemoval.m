function GenRemoval(position, removevector, removaltime)
%generic removal function for distractor removal and response suppression

global M
global P

e = GenEnergy(position, removevector);

F = fieldnames(M);

if isempty(find(strcmp(F, 'esub1')))  %if no esub1 exists yet, set it to e, and asymptote = 1
     M.esub1 = e;
     rasy = 1; 
else
     rasy = logist(e/M.esub1); 
end

strength = rasy*(1-exp(-P.removalrate*removaltime));
M.w = M.w - strength * M.cue(position,:)'* removevector;
