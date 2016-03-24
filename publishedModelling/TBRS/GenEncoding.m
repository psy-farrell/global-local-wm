function encduration = GenEncoding(position, item, list, tau, rate, maxtime, postrehearsal)

global E
global C
global P
global M


if item > 0, 
    stimvector = M.stim(item,:);  %the next to be encoded item vector (either the presented item or the retrieved item during rehearsal)
else
    stimvector = zeros(1, C.un);   %in case an omission occurred during refreshing: nothing is encoded
end
r = max(0.1, rate + randn*P.ratesd);  %random variation of rate 
encduration = min(maxtime, -log(1-tau)/r);  %solving the exponential growh function for time after setting strength = tau --> actual encoding time until tau is reached

%decay during encoding - must happen before encoding, because otherwise the
%to-be-encoded position decays "during" its own encoding, potentially losing
%more than gaining
M.w = M.w * exp(-P.decay*encduration);  

%encoding into WM
strength = 1-exp(-r*encduration);   %in most cases this should be = tau, except where t exceeds maxtime, so encduration < t. 
M.w = M.w + (P.learnasymptote-M.w) .* strength .* (M.cue(position,:)' * stimvector);

if ~isempty(M.trace), M = GetTrace(M, P, list, encduration); end  %trace 2 - after encoding 

% post-encoding rehearsal (including continuing decay of non-rehearsed positions)
if C.rstrategy == 1 && postrehearsal == 1
    M.posfocus = 1;  %reset focus to start of the list to begin rehearsal there
    GenRefresh((E.enctime - encduration), list, 1, M.inpos); 
end
if C.rstrategy == 0 && postrehearsal == 1  %if this is a main Encoding event (not a rehearsal event), and there is no rehearsal: let everything decay in the time of passivity
    M.w = M.w * exp(-P.decay*(E.enctime-encduration));  
end