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
warning('off', 'MATLAB:divideByZero');  %suppresses warnings about division by zero, which occurs frequently during computation of rehearsal accuracy

rand('state',sum(100*clock));  %initializes random generator
randn('state',sum(100*clock));


E.stimuli = [2,1];
if experiment == 10    %Complex span with global-local (1) distractor effect
	% Complex span experimental parameters
	E.maxstor = 9;       %maximum list length (= storage demand)
	E.setsize = 5;
	E.opnum = [3, 12];                     %number of operations following each item
	E.dburstpd = 6.0;                      % period for distractor operations following each item
	E.opduration = [0.3];                  %time for doing easy/hard processing step.
	E.freetime = (E.dburstpd./E.opnum)-E.opduration;     %presentation times for operation at high/low rate.
	E.dsim(1,:)= 0.5;
	E.dsim(2,:) = 0.5;
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
	E.opduration = [0.963, 0.678];
	%time for doing easy/hard processing step, switch cost time = 0.242
	E.freetime = 0.1;                   %presentation times for operation at high/low rate.
	E.dsim(1,:)= 0.5;
	E.dsim(2,:) = 0.5;
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
	E.opduration = [0.30];                 %time for doing easy/hard processing step.
	E.freetime = (E.dburstpd./E.opnum)-E.opduration;     %presentation times for operation at high/low rate.
	E.dsim(1,:)= 0.5;
	E.dsim(2,:) = 0.5;
	E.enctime = 1.4;   %presentation time for an item
	E.simcond = 3;     %1 = all dissimilar, 2 = all similar, 3 = random mixture, 4 = alternating list of word items
	E.wl = 1;          %word length, in syllables (currently not used)
	E.distvar = 3;     %variation in distractor pattern (0=fixed, 1=GL variation in number, 2=GL variation in modality, 3=GL variation for dual slow exception burst)
	E.switchtime = 0; %switch cost in seconds
	E.maxglbcond = 1;  %number of global local conditions - slow/fast; fast/slow
	C.maxdistr = 12;
end

if E.tracing == 0, E.trialnum = 4; E.rehcond = 0; end   %full model

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

fid = fopen (['SOB.GlobLoc', mat2str(E.distvar), '.out'], 'w');
O.SP1 = zeros(E.nreplic, ncond, E.setsize); %Serial position store
O.SP2 = zeros(E.nreplic, ncond, E.setsize); %Serial position store

% calculate times for switch distractors
if E.switchtime > 0
	E.opduration = [E.opduration(:); E.opduration(:) + E.switchtime];
end

for dsim = 1:size(E.dsim,2)  %similarity between distractors
	C.dsim = E.dsim(:,dsim);
	
	for id = 1:E.nreplic
		
		%Generate vectors for position markers in context layer
		M.cue = GenContext(C.cuesim);
		
		%Generate the WM stimuli (including semantic features - so far not used)
		GenStimuli(E.stimuli(1), E.stimuli(2));  %creates stimuli (letters) and distractors (digits)
		
		trialcon = GenGLtrialcondtns;   %set up trial conditions for global local task
		
		for globloc = 1:E.maxglbcond   %loops through global bursts between all spoken/all typed
			for exceptpos = 1:ncond   % loops through trials for each control/exception condition.
				
				localpos = ((globloc-1)*(E.setsize+1))+exceptpos;  % points to appropriate trial in trialcon
				Serpos = zeros(E.trialnum, E.setsize); %initialize serial-position variable
				M.w = randn(C.cun, C.un).*P.nsubo;  %for SOB encoding to cues, assign randomised values in weights matrix
				
				for trial = 1:E.trialnum
					if E.tracing > 0, M.trace = zeros(E.setsize, 50); M.tpos = 1; else M.trace = []; end  %initialize trace
					
					M.w = P.PI*M.w;
					if P.PI == 0, M.w = randn(C.cun, C.un).*P.nsubo; end %for the standard no-PI version of SOB
					
					%Generate list
					list = GenList(E.setsize, 2, E.opnum(1));
					
					%Encoding and processing of distractors
					for item = 1:E.setsize
						M.inpos = item;
						M.position = item;    %sets focus of attention
						M.lastitem = item;    %records current position in the list
						GenEncoding(M.stim(list(item),:), list, E.enctime);
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
					
					%saving data
					fprintf (fid, '%3.0f %2.0f %1.2f %1.2f %1.2f %1.2f %1.2f %1.0f    %1.0f %1.0f %1.0f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %2.1f   %3.2f %3.2f %3.2f %1.2f    %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f   %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f \n', ...
						id, model, globloc, exceptpos, E.dsim(dsim), E.opduration(od), E.freetime(ot), E.opnum(on),  ...
						P.contextstyle, P.disambig, P.recallset, P.threshold, P.nsubo, P.c, P.rate, P.removalrate, P.tau, P.gain,  ...
						C.sim(1), C.itemdistsim, C.cuesim, C.rectime, ...
						list9, recall9);
					
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
	
	fclose(fid);
	
	% Recall data plots: overall recall avereaged across exception position,
	% recall for control and exception position curves, recall for difference
	% curves (exception-control), alignment curves.
	
	O.MSP1 = squeeze(mean(O.SP1,1));
	O.Mrecall(1,:) = O.MSP1(1,:);
	O.Mrecall(2,:) = mean((O.MSP1(2:end,:)),1);
	O.Diff1 = GenDiff (O.MSP1);
	O.DAlign(1,:) = GenAlign(O.Diff1);
	
	if E.distvar ==3
		
		PreFigure(1,[],3);
		plot(O.Mrecall');
		legend(recallegtext(3:4));
		title(['Recall probability across exception conditions']);
		PostFigure([0, E.setsize+1, 0, 1], 'Serial Position', 'P(recall)');
		%PostFigure('auto', 'Serial Position', 'P(recall)');
		
		PreFigure(1,[],3);
		plot(O.MSP1');
		legend(splegtext(1:ncond));
		title(['Recall probability for ', recallegtext{4}]);
		PostFigure([0, E.setsize+1, 0, 1], 'Serial Position', 'P(recall)');
		%PostFigure('auto', 'Serial Position', 'P(recall)');
		
		PreFigure(1,[],3);
		plot(O.Diff1');
		legend(difflegtext(1:ncond-1));
		title(['Difference curves (exceptn - ctrl) for ',recallegtext{4}]);
		PostFigure([0, E.setsize+1, -0.5, 0.5], 'Item Position', 'P(diff)');
		%PostFigure('auto', 'Item Position', 'P(diff)');
		
		PreFigure(1,[],3);
		plot(O.Diff1);
		legend(distposlegtext(1:ncond));
		title(['Item position difference curves for ',recallegtext{4}]);
		PostFigure([0, E.setsize, -0.5, 0.5], 'Exception Position', 'P(diff)');
		%PostFigure('auto', 'Exception Position', 'P(diff)');
		
		%         PreFigure(1,[],3);
		%         plot(O.SPAlign');
		%         legend(alignlegtext(1:E.maxglbcond));
		%         title(['Recall aligned around exception position']);
		%         PostFigure([0, 5, 0, 1], 'Exception Position', 'P(recall)');
		%         %PostFigure('auto', 'Exception Position', 'P(recall)');
		
		PreFigure(1,[],3);
		plot(O.DAlign');
		legend(alignlegtext(1:E.maxglbcond));
		title(['Difference aligned around exception position']);
		PostFigure([0, 5, -0.5, 0.5], 'Exception Position', 'P(diff)');
		%PostFigure('auto', 'Exception Position', 'P(diff)');
		
	else
		
		O.MSP2 = squeeze(mean(O.SP2,1));
		O.Mrecall(3,:) = O.MSP2(1,:);
		O.Mrecall(4,:) = mean((O.MSP2(2:end,:)),1);
		O.Diff2 = GenDiff (O.MSP2);
		
		O.SPAlign(2,:) = GenAlign(O.MSP2(2:end,:));
		O.DAlign(2,:) = GenAlign(O.Diff2);
		
		PreFigure(1,[],3);
		plot(O.Mrecall');
		legend(recallegtext(1:4));
		title(['Recall probability across exception conditions']);
		PostFigure([0, E.setsize+1, 0, 1], 'Serial Position', 'P(recall)');
		%PostFigure('auto', 'Serial Position', 'P(recall)');
		
		PreFigure(1,[],3);
		plot(O.MSP1');
		legend(splegtext(1:ncond));
		title(['Recall probability for ', recallegtext{2}]);
		PostFigure([0, E.setsize+1, 0, 1], 'Serial Position', 'P(recall)');
		%PostFigure('auto', 'Serial Position', 'P(recall)');
		
		PreFigure(1,[],3);
		plot(O.MSP2');
		legend(splegtext(1:ncond));
		title(['Recall probability for ', recallegtext{4}]);
		PostFigure([0, E.setsize+1, 0, 1], 'Serial Position', 'P(recall)');
		%PostFigure('auto', 'Serial Position', 'P(recall)');
		
		PreFigure(1,[],3);
		plot(O.Diff1');
		legend(difflegtext(1:ncond-1));
		title(['Difference curves (exceptn - ctrl) for ',recallegtext{2}]);
		PostFigure([0, E.setsize+1, -0.5, 0.5], 'Item Position', 'P(diff)');
		%PostFigure('auto', 'Item Position', 'P(diff)');
		
		PreFigure(1,[],3);
		plot(O.Diff2');
		legend(difflegtext(1:ncond-1));
		title(['Difference curves (exceptn - ctrl) for ',recallegtext{4}]);
		PostFigure([0, E.setsize+1, -0.5, 0.5], 'Item Position', 'P(diff)');
		%PostFigure('auto', 'Item Position', 'P(diff)');
		
		PreFigure(1,[],3);
		plot(O.Diff1);
		legend(distposlegtext(1:ncond-1));
		title(['Item position difference curves for ',recallegtext{2}]);
		PostFigure([0, E.setsize+1, -0.5, 0.5], 'Exception Position', 'P(diff)');
		%PostFigure('auto', 'Exception Position', 'P(diff)');
		
		PreFigure(1,[],3);
		plot(O.Diff2);
		legend(distposlegtext(1:ncond-1));
		title(['Item position difference curves for ',recallegtext{4}]);
		PostFigure([0, E.setsize+1, -0.5, 0.5], 'Exception Position', 'P(diff)');
		%PostFigure('auto', 'Exception Position', 'P(diff)');
		
		PreFigure(1,[],3);
		plot(O.SPAlign');
		legend(alignlegtext(1:E.maxglbcond));
		title(['Recall aligned around exception position']);
		PostFigure([0, 4, 0, 1], 'Exception Position', 'P(recall)');
		%PostFigure('auto', 'Exception Position', 'P(recall)');
		
		PreFigure(1,[],3);
		plot(O.DAlign');
		legend(alignlegtext(1:E.maxglbcond));
		title(['Difference aligned around exception position']);
		PostFigure([0, 4, -0.5, 0.5], 'Exception Position', 'P(diff)');
		%PostFigure('auto', 'Exception Position', 'P(diff)');
	end
	
	% Summary data, record for plotting in R
	
	
	fid2 = fopen(['gl', mat2str(E.distvar), 'sobpred.dat'], 'w');
	for i = 1:size(O.MSP1,1)
		for j = 1:size(O.MSP1,2)
			fprintf(fid2, '%d ', O.MSP1(i,j));
		end
	end
	if E.distvar < 3
		for i = 1:size(O.MSP2,1)
			for j = 1:size(O.MSP2,2)
				fprintf(fid2, '%d ', O.MSP2(i,j));
			end
		end
	end
	for i = 1:size(O.DAlign,1)
		for j = 1:3
			fprintf(fid2, '%d ', O.DAlign(i,j));
		end
	end
	fclose(fid2);
	
end  %dsim


end