function GenStimuli(itemset, distractorset)
%GenStimuli(itemset, distractorset)

global C;
global E;
global M;

if itemset == 1, E.vocabsize = 9; end %digits
if itemset == 2, E.vocabsize = 16; end %letters - only 16 consonants are created from MDS solution
if itemset > 2, E.vocabsize = max(9, E.maxstor); end  %words: N x N words are created

%%%%% Creation of Stimuli %%%%%%%%%%%%%%%

if itemset == 1   %digits
    prototype = sign(rand(1,C.un)-0.5);  %prototype for the n dissimilar items
    for i = 1:9
        listitems(i,:) = GenGetsimvec(sqrt(C.sim(1)),prototype);  % create 9 dissimilar items
    end 
end

if itemset == 2 %letters
    [listitems, prototype] = GenStimuliLetters;
end

if itemset == 3 || itemset == 4 %words
    protosim = sqrt(C.sim(1)/C.sim(2));  %similarity of set prototypes to master prototype (determines sim of dissimilar items, which is C.sim(1) = protosim*C.sim(2))
    sim = sqrt(C.sim(2));          %similarity of items to set prototype (determines sim of similar items, which is sim(proto, item1)*sim(proto, item2) = C.sim(2)*C.sim(2))
    if itemset == 4, sim = C.sim(2); end %for rhyming words, similarities are not multiplied because keep-probabilities are not independent but perfectly correlated
    listitems=zeros(E.vocabsize^2,C.un);     %create item matrix for encoding item similarity lists
    prototype = sign(rand(1,C.un)-0.5);  %super-prototype for the E.vocabsize dissimilar sets of similar items
    for i = 1:E.vocabsize
        p(i,:) = GenGetsimvec(protosim, prototype);  % create E.vocabsize dissimilar prototypes as seeds for sets of similar items
    end                                              
    for i=1:E.vocabsize
        for j=1:E.vocabsize
            listitems((i-1)*E.vocabsize+j,:)= GenGetsimvec(sim, p(i,:), itemset-2); % create similarity items for each prototype
                           % itemset-2 serves as parameter to decide between non-rhyming (1) or rhyming (2) similarity structure
        end
    end
end

M.stim = listitems;

%%%%% Construct Distractors %%%%%%

if distractorset > -1, 
    distractors = zeros(E.vocabsize, max(E.opnum), C.un);  % create distractor vector matrix. 
end
% If distractorset = 0 (non-verbal distractors), distractors remain vectors of zeros

if ismember (distractorset, [1,2])  %for digits or letters as distractors
    % create set of distractors
    if distractorset == itemset, distitems = listitems;   
    else
        protodist = GenGetsimvec(C.itemdistsim, prototype);  %derive prototype of distractors from prototype of items to control similarity between the two sets
        if distractorset == 1
            for i = 1:9
                distitems(i,:) = GenGetsimvec(sqrt(C.sim(1)), protodist); 
            end
        end
        if distractorset == 2
            distitems = GenStimuliLetters(protodist); 
        end
	end
	if C.offun<C.un
		distitems(:,C.offun:C.un) = 0;
	end
	
    % assign distractors to items of the vocabulary and within-burst positions at random
    for i=1:size(M.stim,1)
        selection = [];
        while length(selection) < max(E.opnum)
            selection = [selection, randperm(size(distitems,1))];
        end
        for k=1:max(E.opnum)
           distractors(i,k,:) = distitems(selection(k),:);
        end
    end
    
end

if ismember(distractorset, 3:4)   %if distractors are words... 
    if itemset < 3     %... and if items are not words 
        wsim = C.dsim(1);   % within-burst similarity
        bsim = C.dsim(2);   % between-burst similarity
        protodist = GenGetsimvec(C.itemdistsim, prototype);  %derive prototype of distractors from prototype of items to control similarity between the two sets
        if bsim < wsim
             bsimcorr = bsim/wsim;  %corrected bsim determines sim between prototypes of bursts, of which distractors are derived through dsim; thus sim between actual distractors of different bursts = bsimcorr*dsim
             for i=1:E.vocabsize
                 burstproto = GenGetsimvec(sqrt(bsimcorr), protodist);    % creates a prototype for current distractor burst from distractor prototype - use sqrt because similiarity between burstproto from 2 different bursts = sim(bp1,p)*sim(p,bp2)
                 %Former Jc parameter corresponds to sqrt(bsim/dsim) now!!! So bsim = Jc^2*dsim
                 for k=1:max(E.opnum)   %for each of the distractor positions for each item
                     distractors (i,k,:) = GenGetsimvec(sqrt(wsim),burstproto, distractorset-2);  %create a single distractor vector for the current distractor position        
                 end
             end
        else
             wsimcorr = wsim/bsim;
             for k=1:max(E.opnum)
                 distrpositionproto = GenGetsimvec(sqrt(wsimcorr), protodist);  %creates a prototype for current distractor position within a burst
                 for i=1:E.vocabsize
                     distractors (i,k,:) = GenGetsimvec(sqrt(bsim), distrpositionproto); %create a single distractor for current burst from prototype of distractor position
                 end
             end
        end
    end
    if itemset > 2  %if items are words, too
        wsim = sqrt(C.dsim(1)); %within-burst similarity. Between-burst similarity is indirectly controlled by similarity between items (see below)
        if distractorset == 4, wsim = C.dsim(1); end %for rhyming words, similarities are not multiplied because keep-probabilities are not independent but perfectly correlated
        for i=1:E.vocabsize  %for the n dissimilar sets of similar items
            for j = 1:E.vocabsize %for the n items in each set of similar items
                burstproto = GenGetsimvec(sqrt(C.itemdistsim), p(i,:));  %burst prototype is derived from item prototype p, so that with dissimilar items, each distractor is similar to its corresponding item
                for k=1:size(distractors,2)   %for each of the distractor positions for each item
                     distractors((i-1)*E.vocabsize+j,k,:) = GenGetsimvec(wsim, burstproto, distractorset-2);  %create a single distractor vector for the current distractor position
                end
            end
        end
    end
end


if distractorset == 5  %if distractors are non-verbal stimuli
   wsim = C.dsim(1);   % within-burst similarity
    bsim = C.dsim(2);   % between-burst similarity
    protodist = GenGetsimvec(C.itemdistsim, prototype);  
    if bsim < wsim
         bsimcorr = bsim/wsim;  %corrected bsim determines sim between prototypes of bursts, of which distractors are derived through dsim; thus sim between actual distractors of different bursts = bsimcorr*dsim
         for i=1:E.vocabsize
             burstproto = GenGetsimvec(sqrt(bsimcorr), protodist);    % creates a prototype for current distractor burst from distractor prototype - use sqrt because similiarity between burstproto from 2 different bursts = sim(bp1,p)*sim(p,bp2)
             %Former Jc parameter corresponds to sqrt(bsim/dsim) now!!! So bsim = Jc^2*dsim
             for k=1:max(E.opnum)   %for each of the distractor positions for each item
                 distractors(i,k,:) = GenGetsimvec(sqrt(wsim),burstproto);  %create a single distractor vector for the current distractor position   
                 deletion = round(length(protodist)*(1-M.ov));
                 if distractorset == 6, distractors(i,k,1:deletion) = zeros(1,deletion); end %sets proportion 1-M.ov to zero 
             end
         end
    else
         wsimcorr = wsim/bsim;
         for k=1:max(E.opnum)
             distrpositionproto = GenGetsimvec(sqrt(wsimcorr), protodist);  %creates a prototype for current distractor position within a burst
             for i=1:E.vocabsize
                 distractors (i,k,:) = GenGetsimvec(sqrt(bsim), distrpositionproto); %create a single distractor for current burst from prototype of distractor position
             end
         end
    end
end

if distractorset > -1
    M.distr = distractors;
end

%by default generate candidates for recall - including whole vocabulary of memory items but
%no distractors. Can be overwritten later
[M.candidates, M.recallset] = GenRecallset(1:size(listitems,1),0); 


