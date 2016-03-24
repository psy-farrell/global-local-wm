function [candvectors, recallset] = GenRecallset(itemcands, burstlength)
%constructs the set of recall candidates for SOB, using list to select the memory items to include, 
% and using length(list) and burstlength as arguments to select the distractors to include

global M
global E

if nargin < 1, itemcands = 1:size(M.stim,1); burstlength = 0; end %default: all vocabulary items, no distractors
if nargin < 2, burstlength = 0; end

% item candidates
candvectors = M.stim(itemcands,:);
recallset = itemcands;

%add distractor candidates only if distractors come from same category as items
%(that would be the case also if one = 3, non-rhyming words, and the other = 4, rhyming words)

if E.stimuli(2) == E.stimuli(1) || (ismember(E.stimuli(1), [3,4]) && ismember(E.stimuli(2), [3,4])); 
    if E.stimuli(2) < 3 && burstlength > 0  %in case of digit or letter distractors: don't add every token, just add all types
        candvectors = M.stim;
        recallset = [recallset, -3*ones(1,size(M.stim,1)-length(itemcands))];
    else                                    %in case of words (or in case of burstlength = 0)
        for i = 1:burstlength
            candvectors = [candvectors; squeeze(M.distr(itemcands,i,:))];
            recallset = [recallset, -3*ones(1,length(itemcands))]; %marks distractors by "-3"
        end
    end
end

recallset = [recallset, -4]; %for omissions 
