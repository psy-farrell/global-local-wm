function learnrate = GenEncoding(stimvector, encduration)
%always associates the position marker of M.position to the stimvector

global P
global M

cuevector = M.cue(M.position,:);
e = GenEnergy(M.position, stimvector);   %calculates energy (novelty)
Asymptote = logist(e, P.tau, P.gain);    %asymptotic encoding strength
learnrate = Asymptote * (1-exp(-encduration * P.rate));  %actual encoding strength
M.w = M.w + learnrate * (cuevector' * stimvector); 




