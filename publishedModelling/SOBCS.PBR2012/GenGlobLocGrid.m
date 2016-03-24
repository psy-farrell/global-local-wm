% SOB applied to Global Local/modality switch complex span experiment

function GenGlobLoc(model, experiment)

% In this version of the Global Local Complex span task, the global/local
% manipulation is the modality of the distractors, switching between
% speaking and typing, thus controlling for cognitive load.  The model is
% tested when the majority condition is speaking, with a single distractor
% burst requiring typing of distractor items and vice versa.  Switch costs
% are accounted for for the first item of a switched distractor burts, i.e.
% switching from typing to speaking incurs an additional time requirement
% for the change of modality and likewise in switching back following the
% local burst, to typing.

global E   %experiment parameters
global C   %constants
global P   %model parameters
global M
global O

clear PC; clear MeanPC;
%warning('off', 'MATLAB:divideByZero');  %suppresses warnings about division by zero, which occurs frequently during computation of rehearsal accuracy

rand('state',sum(100*clock));  %#ok<RAND> %initializes random generator
randn('state',sum(100*clock)); %#ok<RAND>

E.stimuli = [2, 1];

if experiment == 10    %Complex span with global-local (1) distractor effect
	% Complex span experimental parameters
	E.maxstor = 9;       %maximum list length (= storage demand)
	E.setsize = 5;
	E.opnum = [3, 12];                     %number of operations following each item
	E.dburstpd = 6.0;                      % period for distractor operations following each item
	E.opduration = [0.3 0.3];                  %time for doing easy/hard processing step.
	E.freetime = (E.dburstpd./E.opnum)-E.opduration;     %presentation times for operation at high/low rate.
	E.dsim(1,:)= 0.5;
	E.dsim(2,:) = 0.5; %0.31^2 * E.dsim(1,:); %this is to ensure that Jc = 0.31
	E.enctime = 1.4;   %presentation time for an item
	E.simcond = 3;     %1 = all dissimilar, 2 = all similar, 3 = random mixture, 4 = alternating list of word items
	E.wl = 1;          %word length, in syllables (currently not used)
	E.distvar = 1;     %variation in distractor pattern (0=fixed, 1=GL variation in number, 2=GL variation in modality, 3=GL variation for dual slow exception burst)
	E.switchtime = 0; %switch cost in seconds
	E.maxglbcond = 2;  %number of global local conditions - slow/fast; fast/slow
	C.maxdistr = 12;
	C.itemdistsim = 0.2;
end


if experiment == 11    %Complex span with global-local (2) distractor (modality switching) effect
	% Complex span experimental parameters
	E.maxstor = 9;       %maximum list length (= storage demand)
	E.setsize = 5;
	E.opnum = 3;                        %number of operations following each item
	E.dburstpd = 6.0;                   % period for distractor operations following each item
	E.opduration = [0.963, 0.678];     %time for doing easy/hard processing step, switch cost time = 0.242
	E.freetime = 0.1;                   %presentation times for operation at high/low rate.
	E.dsim(1,:)= 0.5;
	E.dsim(2,:) = 0.5; %0.31^2 * E.dsim(1,:); %this is to ensure that Jc = 0.31
	E.enctime = 1.4;   %presentation time for an item
	E.simcond = 3;     %1 = all dissimilar, 2 = all similar, 3 = random mixture, 4 = alternating list of word items
	E.wl = 1;          %word length, in syllables (currently not used)
	E.distvar = 2;     %variation in distractor pattern (0=fixed, 1=GL variation in number, 2=GL variation in modality, 3=GL variation for dual slow exception burst)
	E.switchtime = 0.242; %switch cost in seconds
	E.maxglbcond = 2;  %number of global local conditions - typed/spoken; spoken/typed
	C.phun = 75; %number of phonological units that are set to zero for typed digits
end


if experiment == 12    %Complex span with global-local (3) distractor (dual slow burst) effect
	% Complex span experimental parameters
	E.maxstor = 9;       %maximum list length (= storage demand)
	E.setsize = 5;
	E.opnum = [3, 12];                     %number of operations following each item
	E.dburstpd = 6.0;                      % period for distractor operations following each item
	E.opduration = [0.30 0.3];                 %time for doing easy/hard processing step.
	E.freetime = (E.dburstpd./E.opnum)-E.opduration;     %presentation times for operation at high/low rate.
	E.dsim(1,:)= 0.5;
	E.dsim(2,:) = 0.5;  %0.31^2 * E.dsim(1,:); %this is to ensure that Jc = 0.31
	E.enctime = 1.4;   %presentation time for an item
	E.simcond = 3;     %1 = all dissimilar, 2 = all similar, 3 = random mixture, 4 = alternating list of word items
	E.wl = 1;          %word length, in syllables (currently not used)
	E.distvar = 3;     %variation in distractor pattern (0=fixed, 1=GL variation in number, 2=GL variation in modality, 3=GL variation for dual slow exception burst)
	E.switchtime = 0; %switch cost in seconds
	E.maxglbcond = 1;  %number of global local conditions - slow/fast; fast/slow
	C.maxdistr = 12;
end

E.trialnum = 4;
E.rehcond = 0;

if E.distvar == 1 || E.distvar == 3  % Varying number of distractor items in processing model
	recallegtext{1} = 'global slow';
	recallegtext{2} = 'global slow/exception fast';
	recallegtext{3} = 'global fast';
	recallegtext{4} = 'global fast/exception slow';
	alignlegtext{1} = 'slow global/fast local';
	alignlegtext{2} = 'fast global/slow local';
	od=1;
else   % Switched modality distractor processing model
	recallegtext{1} = 'global type';
	recallegtext{2} = 'global type/exception speech';
	recallegtext{3} = 'global speech';
	recallegtext{4} = 'global speech/exception type';
	alignlegtext{1} = 'type global/speech local';
	alignlegtext{2} = 'speech global/type local';
	ot=1;
	on=1;
end

if E.distvar == 3, ncond = E.setsize; else ncond = E.setsize+1; end

sprintf('Global Local model %d.', E.distvar)

O.SP1 = zeros(E.nreplic, ncond, E.setsize); %Serial position store
O.SP2 = zeros(E.nreplic, ncond, E.setsize); %Serial position store

% calculate times for switch distractors
if E.switchtime > 0
	E.opduration = [E.opduration(:); E.opduration(:) + E.switchtime];
end

G1 = [0.35 0.5 0.65];
G2 = [4 6 10];
G3 = [1 1.5 2];
G4 = [-750 -1000 -1250];
G5 = [.0022 0.0033 .0055];

for g1 = 1:length(G1)
for g2 = 1:length(G2)
for g3 = 1:length(G3)
for g4 = 1:length(G4)
for g5 = 1:length(G5)
	
C.cuesim = G1(g1);			%cue similarity
P.rate = G2(g2);            %rate of encoding
P.removalrate = G3(g3);     %rate of removal 
P.tau = G4(g4);             %shift of logistic for computation of strength from Energy
P.gain = G5(g5);            %gain of logistic for computation of strength from Energy

[g1 g2 g3 g4 g5]
	
for dsim = 1:size(E.dsim,2)  %similarity between distractors
	C.dsim = E.dsim(:,dsim);
	
	for id = 1:E.nreplic
		
		%Generate vectors for position markers in context layer
		M.cue = GenContext(C.cuesim);
		
		%Generate the WM stimuli (including semantic features - so far not used)
		GenStimuli(E.stimuli(1), E.stimuli(2));  %creates stimuli and distractors 
		
		trialcon = GenGLtrialcondtns;   %set up trial conditions for global local task
		
		for globloc = 1:E.maxglbcond   %loops through global bursts between all spoken/all typed
			for exceptpos = 1:ncond   % loops through trials for each control/exception condition.
				
				localpos = ((globloc-1)*(E.setsize+1))+exceptpos;  % points to appropriate trial in trialcon
				Serpos = zeros(E.trialnum, E.setsize); %initialize serial-position variable
				M.w = randn(C.cun, C.un).*P.nsubo;  %for SOB encoding to cues, assign randomised values in weights matrix
				
				for trial = 1:E.trialnum
					
					M.w = randn(C.cun, C.un).*P.nsubo; 
					
					%Generate list
					list = GenList(E.setsize, 2, E.opnum(1));
					
					%Encoding and processing of distractors

					
					for item = 1:E.setsize
						M.position = item;   %records current position in the list
						M.opnumber = 0;
						GenEncoding(M.stim(list(item),:), E.enctime);
						E.curdistrstate = trialcon(localpos,item); %set current distractor state for distractor processing
						if E.distvar == 1 || E.distvar ==3,
							on = E.curdistrstate;
							ot = E.curdistrstate;
						end
											
						for op = 1:E.opnum(on)     %distractor processing loop

							M.opnumber = op;
							if E.distvar == 2
								if (item > 1) && (op == 1) && (E.curdistrstate ~= trialcon(localpos,item-1))  % tests for change of modality in distractors between trial items
									od = E.curdistrstate + E.maxglbcond;   %set time flag to select operation duration for current modality switch
								else
									od = E.curdistrstate;  %does not include switch cost due to change of modality
								end
							end
							GenProcess(list, od, ot);
						end
					end
					
					
					%Recall
					recall = zeros(1,E.setsize);
					correct = zeros(1,E.setsize);
					for probedpos = 1:E.setsize %it is possible to probe for recall in any order, but in complex span, usually recall is in forward order
						M.position = probedpos;
						[recall(probedpos), correct(probedpos)] = GenRecall(list, probedpos);
					end
					
					%collecting data
					Serpos(trial, :) = correct;
					list9 = [list, zeros(1,9-length(list))];
					recall9 = [recall, zeros(1,9-length(recall))];
					
				end  %trial
				
				%locposx = localpos+1;
				if globloc == 1,
					O.SP1(id,exceptpos,:) = mean(Serpos, 1);
				else
					O.SP2(id,exceptpos,:) = mean(Serpos, 1);
				end
				
			end %exceptpos - control/exception distractor positions
			
		end %globloc - rotation of global distractor conditions
		
	end  %id
	
	% Recall data plots: overall recall avereaged across exception position,
	% recall for control and exception position curves, recall for difference
	% curves (exception-control), alignment curves.
	
	O.MSP1 = squeeze(mean(O.SP1,1))';
	O.Diff1 = GenDiff (O.MSP1');
	O.DAlign(1,:) = GenAlignSF(O.Diff1);
	
	outSeq = [C.cuesim P.rate P.removalrate P.tau P.gain];            %gain of logistic for computation of strength from Energy];
	outSeq = [outSeq O.MSP1(:)'];
	
	if E.distvar ~=3
		
		O.MSP2 = squeeze(mean(O.SP2,1))';
		O.Diff2 = GenDiff (O.MSP2');
		O.DAlign(2,:) = GenAlignSF(O.Diff2);
		
		outSeq = [outSeq O.MSP2(:)'];
	end
	
	% Summary data, record for plotting in R
	
	kk = O.DAlign';
	outSeq = [outSeq kk(:)'];
	
	save(['SOB.GlobLocGrid' num2str(experiment) '.out'],'outSeq','-append','-ascii');

end
	
end  %dsim

state = [g1 g2 g3 g4 g5]

end % outer loops across parameters
end
end
end
end