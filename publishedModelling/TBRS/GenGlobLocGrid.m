% TBRS model applied to Global Local experiments

function GenGlobLocGrid(model, experiment)

global E   %experiment parameters
global C   %constants
global P   %model parameters
global M   %record of memory states

warning('off', 'MATLAB:divideByZero');  %suppresses warnings about division by zero, which occurs frequently during computation of rehearsal accuracy

rand('state',sum(100*clock));  %initializes random generator
randn('state',sum(100*clock));

E.distvar = experiment-8; %model 9 = GL1, 10 = GL2, 11 = GL3
E.setsize = 5;
E.trialnum = 4;
E.dburstpd = 6.0;   % period for distractor operations following each item
E.enctime = 1.5;    %presentation time for an item

if E.tracing == 1, E.trialnum = 1; E.nreplic = 1; end;

if E.distvar == 1 || E.distvar == 3  % Varying number of distractor items in processing model
    E.opnum = [3, 12];
    E.opduration = [0.3, 0.3];                  %[0.25 0.25] time for processing step.
    E.freetime = (E.dburstpd./E.opnum)-E.opduration;     %presentation times for operation at high/low rate.
    recallegtext{1} = 'global slow';
    recallegtext{2} = 'global slow/exception fast';
    recallegtext{3} = 'global fast';
    recallegtext{4} = 'global fast/exception slow';
    alignlegtext{1} = 'slow global/fast local';
    alignlegtext{2} = 'fast global/slow local';
else   % Switched modality distractor processing model
    E.opnum = [3, 3];                        %number of operations following each item
    E.opduration = [0.963, 0.678];      %time for doing easy/hard processing step, switch cost time = 0.242
    E.freetime = [0.1, 0.1];                   %presentation times for operation at high/low rate.
    recallegtext{1} = 'global type';
    recallegtext{2} = 'global type/exception speech';
    recallegtext{3} = 'global speech';
    recallegtext{4} = 'global speech/exception type';
    alignlegtext{1} = 'type global/speech local';
    alignlegtext{2} = 'speech global/type local';
end
E.oprate = -log(1-C.tau)./E.opduration; %convert mean operation times into mean rates
if E.distvar == 3, E.maxglbcond = 1; else E.maxglbcond = 2; end
if E.distvar == 3, ncond = E.setsize; else ncond = E.setsize+1; end

%defines the set of conditions depending on experiment
if E.distvar ~= 3
    condition = [repmat(1, ncond, E.setsize);
        repmat(2, ncond, E.setsize)];
    for h = 1:E.maxglbcond
        for i = 2:ncond
            condition(((h-1)*ncond)+i,i-1) = 3-condition(((h-1)*ncond)+i,i-1);  %change one serial position to other load/task (2-->1, 1-->2)
        end
    end
else
    condition = repmat(2, ncond, E.setsize);     %all high load
    for i = 2:ncond
        condition(i,i-1:i) = 1;  %change 2 adjacent serial positions to low load
    end
end

inoutmatrix = zeros(E.setsize,E.setsize,size(condition,1));
ommcurve = zeros(size(condition,1),E.setsize);
intcurve = zeros(size(condition,1),E.setsize);

sprintf('Global Local model %d.', E.distvar)

for i = 1:E.setsize+1
    if i == 1, splegtext{i} = ['Global distr: '];
    else
        if E.distvar == 3
            splegtext{i} = ['Exceptn posn: ', mat2str(i-1),'-',mat2str(i)];
        else
            splegtext{i} = ['Exceptn posn: ', mat2str(i-1)];
        end
        difflegtext{i-1} = splegtext{i};
        distposlegtext{i-1} = ['Item postn: ' mat2str(i-1)];
    end
end

G1 = [0.3, 0.5, 0.7];  %decay rate
G2 = [4, 6, 8];        %processing rate
G3 = [.05 .08 .15]; % refresh duration
G4 = [.05 .08 .12]; % threshold
G5 = [.01 .02 .05 .1]; % noise

for g1 = 1:length(G1)
for g2 = 1:length(G2)
for g3 = 1:length(G3)
for g4 = 1:length(G4)
for g5 = 1:length(G5)
	
P.decay = G1(g1);
P.rate = G2(g2);
P.rehduration = G3(g3);
P.threshold = G4(g4);
P.noisefactor = G5(g5);

C.rtau = 1-exp(-P.rate*P.rehduration); %computes the threshold required to ensure that the (average) rehearsal duration = P.rehduration

SP1 = zeros(E.nreplic, ncond, E.setsize); %Serial position store
SP2 = zeros(E.nreplic, ncond, E.setsize); %Serial position store

for id = 1:E.nreplic
    
    %Generate vectors for position markers in context layer
    M.cue = GenContext;
    M.stim = eye(C.un);
    
    condr =1;
    
    for globloc = 1:E.maxglbcond   %loops through global bursts between all spoken/all typed
        for exceptpos = 1:ncond   % loops through trials for each control/exception condition.
            
            localpos = ((globloc-1)*(E.setsize+1))+exceptpos;  % points to appropriate line in condition
            Serpos = zeros(E.trialnum, E.setsize); %initialize serial-position variable
            
            for trial = 1:E.trialnum
                if E.tracing > 0, M.trace = zeros(E.setsize, 50); M.tpos = 1; else M.trace = []; end  %initialize trace
                
                M.w = zeros(C.cun, C.un);  %for hebbian associations to cues - reset for each stimulus set
                %Generate list
                list = randperm(size(M.stim,1));  %shuffles the vocabulary
                list = list(1:E.setsize);
                
                %Encoding and processing of distractors
                for item = 1:E.setsize
                    M.inpos = item;   %records current position in the list
                    M.position = item; %records on which position the focus of attention is (for rehearsal)
                    GenEncoding(item, list(item), list, C.tau, P.rate, E.enctime, 1);
                    M.position = 1;  %cumulative rehearsal --> reset position focus to first list item
                    for op = 1:E.opnum(condition(localpos,item))     %distractor processing loop
                        GenProcess2(list, condition(localpos,item));
                    end
                end
                
                
                %Recall
                tint = zeros(1,E.setsize);
                for probedpos = 1:E.setsize
                    M.position = probedpos;
                    [recall(probedpos), correct(probedpos)] = GenRecall(list, probedpos);
                    tint(probedpos) = ~any(recall(probedpos)==list);
                end
                
                intcurve(condr,:) = intcurve(condr,:) + tint;
                
                ommcurve(condr,:) = ommcurve(condr,:) + recall==0;
                
                Serpos(trial, :) = correct(1,1:E.setsize);
                list9 = [list, zeros(1,9-length(list))];
                
                for inpos = 1:E.setsize
                    for outpos = 1:E.setsize
                        if list(inpos) == recall(outpos)
                            %itemrecalled(stor,trial,inpos) = itemrecalled(stor,trial,inpos) + 1;  %counts up how often a list item is recalled anywhere
                            inoutmatrix(outpos,inpos,condr) = inoutmatrix(outpos,inpos,condr) + 1;
                        end
                    end
                end
                
            end  %trial
            
            %locposx = localpos+1;
            if globloc == 1
                SP1(id,exceptpos,:) = mean(Serpos, 1);
            else
                SP2(id,exceptpos,:) = mean(Serpos, 1);
            end
            
            condr = condr+1;
            
        end %exceptpos - control/exception distractor positions
        
    end %globloc - rotation of global distractor conditions
    
end  %id



if E.tracing == 0
    % Recall data plots: overall recall avereaged across exception position,
    % recall for control and exception position curves, recall for difference
    % curves (exception-control), alignment curves.
    
    % control condition (no distractors) is first line in MSP1/MSP2
    
    MSP1 = squeeze(mean(SP1,1))'; % <-- transpose this
	 % MSP1 organized into columns (each col a pos, each row a conditon)
    Diff1 = GenDiff (MSP1');
	%Diff1
	%GenAlignSF(Diff1)
	if exist('DAlign')
		DAlign
	end
    DAlign(1,:) = GenAlignSF(Diff1);
	
	outSeq = [P.decay P.rate P.rehduration P.threshold P.noisefactor];
	outSeq = [outSeq MSP1(:)'];
    
    if E.distvar ~=3 % Is this GL3 (exceptions are always slower)?
        
        MSP2 = squeeze(mean(SP2,1))';
        Diff2 = GenDiff (MSP2');
        DAlign(2,:) = GenAlignSF(Diff2);
		
		outSeq = [outSeq MSP2(:)'];
        
	end
	
	kk = DAlign';
	outSeq = [outSeq kk(:)'];

	save(['TBRS.GlobLocGrid' num2str(experiment) '-' num2str(C.rschedule) '.out'],'outSeq','-append','-ascii');
end

state = [g1 g2 g3 g4 g5]

end % outer loops across parameters
end
end
end
end
