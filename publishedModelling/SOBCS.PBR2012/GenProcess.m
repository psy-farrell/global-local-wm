function learnrate = GenProcess(list, od, ot, distlist)
% Executes 1 distractor operation, removes preceding distractor in the
% remaining time 

global E
global M

if nargin < 4, distlist = list(randperm(length(list))); end   %if no list of distractors is given, shuffle list of items to pick corresponding distractors
   
Distractor = squeeze(M.distr(distlist(M.position), M.opnumber,:))';  %vector of distractor processed in this operation (picks the distractor accompanying the list item)

if E.stimuli(2) == 5,   %for non-verbal stimuli: need to be encoded into M.ws
	learnrate = GenEncodingSpat(Distractor, E.opduration(od)); 
    GenRemovalSpat(M.position, Distractor, E.freetime(ot)); 
else
	learnrate = GenEncoding(Distractor, E.opduration(od));
    GenRemoval(M.position, Distractor, E.freetime(ot)); 
end