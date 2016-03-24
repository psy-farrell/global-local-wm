function list = GenList(stor, itemset, burstlength)
if nargin < 3, burstlength = 0; end
%creates lists for different similarity conditions, defines the
%recall-candidate set

global E
global P
global M

% Selection of list elements

if itemset == 1  % digits - similarity plays no role anyway
    list = [];
    while length(list) < (stor+1)
        list = [list, randperm(9)]; %#ok<AGROW>
    end
end

if itemset == 2  %consonants
    if E.simcond == 1, list = randperm(10) + 6; end %skips over the first 6 stimuli, which are the similar ones
    if E.simcond == 2, list = randperm(6); end  %selects from the similar ones
    if E.simcond == 3, list = randperm(16); end  %random selection from all consonants
    if E.simcond == 4,   %alternating similar & dissimilar, starting with similar 
        list = randperm(10) + 6; %dissimilar items
        simlist = randperm(6); %similar items
        list(1:2:stor) = simlist(1:length(1:2:stor)); %insert similar items at positions 1, 3, 5, ...
    end
    if length(list) < stor, list = [list, randperm(stor-length(list))]; end %fill lists with random stimuli if not enough stimuli of a similarity class are available
end

if itemset == 3 || itemset == 4  %for words
    setlist = randperm(E.maxstor);  %randomization of sets of similar items
    itemlist = randperm(E.maxstor); %randomization of items within sets
    if E.simcond == 1, list = (setlist-1)*E.maxstor + itemlist; end  %picks each item from a different set
    if E.simcond == 2, list = (setlist(1)-1)*E.maxstor + itemlist; end  %picks all item from 1 set
    if E.simcond == 3, list = randperm(3*E.maxstor); end %selects from 3 sets of E.maxstor items to generate a random mix of similar and dissimilar items
    if E.simcond == 4,  %alternating similar & dissimilar, starting with similar 
        list = (setlist-1)*E.maxstor + itemlist;  %dissimilar items
        simlist = (setlist(1)-1)*E.maxstor + itemlist;   %similar items
        simlist = simlist(randperm(stor));  %shuffle order of similar items
        list(1:2:stor) = simlist(1:2:stor); %insert similar items at positions 1, 3, 5, ...
    end
end

list = list(1:stor);  %reduced because length(list) is used in some functions to compute stor

% Definition of the set of recall candidates 
% (except if P.recallset == 2, which is the default, defined in GenStimuli)

if P.recallset == 1, [M.candidates, M.recallset] = GenRecallset(list,0); end        
if P.recallset == 3, [M.candidates, M.recallset] = GenRecallset(list, burstlength); end  
if P.recallset == 4, [M.candidates, M.recallset] = GenRecallset(1:size(M.stim,1), burstlength); end  
if itemset == 4 && E.simcond == 2  %in the similar condition with rhyming words: reduce recall candidates to elements of the rhyming set
    rhymeset = (1:9) + (setlist(1)-1)*E.maxstor;
    [M.candidates, M.recallset] = GenRecallset(rhymeset, 0);
end    


