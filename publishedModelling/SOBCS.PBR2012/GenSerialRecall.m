% Generic WM model applied to Serial Recall

function GenSerialRecall(stimcat)

global E   %experiment parameters
global C   %constants
global P   %model parameters
global M

% Serial Recall experimental parameters
E.maxstor = 9;       %maximum list length (= storage demand)
E.enctime = 0.5;     %presentation time for an item
E.simconds = [1,2,4];     %1 = all dissimilar, 2 = all similar, 4 = alternating
E.setsize = 5:9;
E.opnum = 0; 
E.trialnum = 10;
E.dsim = [0.5; 0.5];      %irrelevant
E.recallmode = 1;  %recall
M.opnumber = 0; 

clear PC; clear MeanPC;
warning('off', 'MATLAB:divideByZero');  %suppresses warnings about division by zero

rand('state',sum(100*clock));  %initializes random generator
randn('state',sum(100*clock)); 

fid = fopen ('SOB.Sspan.out', 'w');

for stim = 1:length(stimcat)
E.stimuli = [stimcat(stim), 0];      %first entry = items, second = distractors; 1 = digits, 2 = letters, 3 = words (nonrhyming), 4 = words (rhyming)

inout = zeros(E.nreplic, max(E.simconds), max(E.setsize), max(E.setsize), max(E.setsize));
poscorr = zeros(E.nreplic, max(E.simconds), max(E.setsize), max(E.setsize));
intrus = zeros(E.nreplic, max(E.simconds), max(E.setsize), max(E.setsize));
omiss = zeros(E.nreplic, max(E.simconds), max(E.setsize), max(E.setsize));
M.trace = [];

for id = 1:E.nreplic
  
%Generate vectors for position markers in context layer
M.cue = GenContext(C.cuesim);
GenStimuli(E.stimuli(1),E.stimuli(2));      

inoutmatrix = zeros(max(E.simconds), max(E.setsize), max(E.setsize), max(E.setsize));

for sim = E.simconds
    E.simcond = sim;

itemrecalled = zeros(max(E.setsize), E.trialnum, max(E.setsize)); 
omission = zeros(E.trialnum, max(E.setsize));
intrusion = zeros(E.trialnum, max(E.setsize)); 

for stor = E.setsize
    
for trial = 1:E.trialnum

    M.w = randn(C.cun, C.un).*P.nsubo; 

    %Generate list
    list = GenList(stor, E.stimuli(1));    % generates lists of consonants
    if P.recallset == 1 || P.recallset == 3, [M.candidates, M.recallset] = GenRecallset(list,0); end

    %Encoding 
    for item = 1:stor
        M.position = item; %records on which position the focus of attention is (for rehearsal)
        GenEncoding(M.stim(list(item),:), E.enctime);
    end

    recall = zeros(1,stor); 
    correct = zeros(1,stor); 
    errortype = zeros(1,max(E.setsize)); 
    for probedpos = 1:stor %it is possible to probe for recall in any order, but usually recall is in forward order
        M.position = probedpos;
        [recall(probedpos), correct(probedpos), errortype(probedpos)] = GenRecall(list, probedpos);
    end

    %collecting data

    for inpos = 1:stor
        for outpos = 1:stor
            if list(inpos) == recall(outpos)
                itemrecalled(stor,trial,inpos) = itemrecalled(stor,trial,inpos) + 1;  %counts up how often a list item is recalled anywhere
                inoutmatrix(sim,stor,inpos,outpos) = inoutmatrix(sim,stor,inpos,outpos) + 1;
            end
        end
    end
    intrusion(trial,:) = errortype == 2;
    omission(trial,:) = errortype == 4; 

end  %trial

inout(id,sim,stor,:,:) = inoutmatrix(sim,stor,:,:)./E.trialnum;
poscorr(id,sim,stor,:) = diag(squeeze(inout(id,sim,stor,:,:)))';
intrus(id,sim,stor,:) = mean(intrusion);
omiss(id,sim,stor,:) = mean(omission);

end  %stor
end  %sim
end  %id
Inout = squeeze(mean(inout));
Poscorr = squeeze(mean(poscorr));
Intrus = squeeze(mean(intrus));
Omiss = squeeze(mean(omiss));
Itemmem = 1-(Intrus+Omiss);        %proportion of responses that match any list item (lenient scoring)

for sim = E.simconds
    for stor = E.setsize
        fprintf(fid, '%2.4f %2.4f %2.4f   %2.4f %2.4f %2.4f %2.4f %2.4f %2.4f %2.4f %2.4f %2.4f   ', stimcat(stim), sim, stor, Poscorr(sim,stor,:)); 
        fprintf(fid, '%2.4f %2.4f %2.4f %2.4f %2.4f %2.4f %2.4f %2.4f %2.4f   ', Itemmem(sim,stor,:)); 
        fprintf(fid, '%2.4f %2.4f %2.4f %2.4f %2.4f %2.4f %2.4f %2.4f %2.4f   ', Omiss(sim,stor,:)); 
        fprintf(fid, '%2.4f %2.4f %2.4f %2.4f %2.4f %2.4f %2.4f %2.4f %2.4f   ', Intrus(sim,stor,:)); 
        fprintf(fid, ' \n');   
    end
end

%plot all serial position curves for dissimilar condition
XY = []; 
for s = E.setsize
    pv(s).x = 1:s;
    pv(s).y = squeeze(Poscorr(1,s,1:s));
    XY = [XY, 'pv(', mat2str(s), ').x, pv(', mat2str(s), ').y' ];
    if s < max(E.setsize), XY = [XY, ', ']; end
end
PreFigure;
eval(['plot(', XY, ')']);
title('Serial Position Curve for Dissimilar Items');
PostFigure([0, max(E.setsize), 0, 1], 'Serial Position', 'P(recall)');

%plot similar vs. dissimilar (vs. alternating) serial position curve for setsize 7
PreFigure
pv = [];
for s = 1:length(E.simconds)
    pv = [pv,squeeze(Poscorr(E.simconds(s),7,1:7))];
end
plot(pv);
title('Correct in Position, 7-item lists');
legend('dissimilar', 'similar', 'alternating');
PostFigure([0, 8, 0, 1], 'Serial Position', 'P(recall)');

%plot similar vs. dissimilar (vs. alternating) serial position curve for
%setsize 7, item memory
PreFigure
pv = [];
for s = 1:length(E.simconds)
    pv = [pv,squeeze(Itemmem(E.simconds(s),7,1:7))];
end
plot(pv);
title('Item Memory, 7-item lists');
legend('dissimilar', 'similar', 'alternating');
PostFigure([0, 8, 0, 1], 'Serial Position', 'P(recall)');

%plot similar vs. dissimilar (vs. alternating) serial position curve for
%setsize 7, intrusion errors
PreFigure
pv = [];
for s = 1:length(E.simconds)
    pv = [pv,squeeze(Intrus(E.simconds(s),7,1:7))];
end
plot(pv);
title('Intrusions, 7-item lists');
legend('dissimilar', 'similar', 'alternating');
PostFigure([0, 8, 0, 1], 'Serial Position', 'P(recall)');

%plot similar vs. dissimilar (vs. alternating) serial position curve for
%setsize 7, omission errors
PreFigure
pv = [];
for s = 1:length(E.simconds)
    pv = [pv,squeeze(Omiss(E.simconds(s),7,1:7))];
end
plot(pv);
title('Omissions, 7-item lists');
legend('dissimilar', 'similar', 'alternating');
PostFigure([0, 8, 0, 1], 'Serial Position', 'P(recall)');

if length(stimcat) == 1

    %plot input-output-matrix for setsize 6, similar
    PreFigure
    pv = squeeze(Inout(2,6,1:6,1:6));
    plot(pv');
    title('Similar Condition');
    legend('inpos1', 'inpos2', 'inpos3', 'inpos4', 'inpos5', 'inpos6'); 
    PostFigure([0, 7, 0, 1], 'Output Position', 'P(recall)');  

    %plot input-output-matrix for setsize 9, similar
    PreFigure
    pv = squeeze(Inout(2,9,:,:));
    plot(pv');
    title('Similar Condition');
    legend('inpos1', 'inpos2', 'inpos3', 'inpos4', 'inpos5', 'inpos6', 'inpos7', 'inpos8', 'inpos9'); 
    PostFigure([0, 10, 0, 1], 'Output Position', 'P(recall)');  

    %plot input-output-matrix for setsize 6, alternating
    PreFigure
    pv = squeeze(Inout(4,6,1:6,1:6));
    plot(pv');
    title('Alternating (starting S)');
    legend('inpos1', 'inpos2', 'inpos3', 'inpos4', 'inpos5', 'inpos6'); 
    PostFigure([0, 7, 0, 1], 'Output Position', 'P(recall)');  

end

clear pv
end  %for stimcat
fclose(fid);