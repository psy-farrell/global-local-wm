% Wrapper for TBRS model - reduced version for publication
%clear all;    

clear all; close all

global E   %experiment parameters
global C   %constants
global P   %model parameters
global O   %outcome variables

experiment = 11;    %1 = Big Complex Span (incl. Simple Span); 2 = BrownPeterson; 3 = simple span 4 = Complex Span experiments with size-comparison task,
                   %5 = Barrouillet 04, E7; 6: Barrouillet et al. 09, E2); 7 = Calendar (encoding), 8 = Variation of timing of bursts 
                   %9 = GlobalLocal 1; 10 = GlobalLocal 2; 11 = GlobalLocal 3; 12 = Barrouillet 2011 nops x pace 
grid = 1;          %0 = no grid, 1 = grid search

% General experimental parameters (common to all simulations) and parameters for controlling simulation
E.maxstor = 9;       %maximum list length (for span procedure) 
E.plotting = 2;      %0 = none, 1 = minimalist, 2 = more (depending on experiment)
E.tracing = 0;       %0 = off, 1 = tracing for visualization; 
E.serposval = 7;     %list length for serial position curve plots
E.nreplic = 200;     %default, can be overwritten in later functions (depending on tracing)

%Constants
C.un = 81;         %number of units for stimuli (total number in the stimulus layer)
C.cn = 6;          %number of units for each cue (= position marker)
C.tau = 0.95;      %threshold of strength at which encoding / processing finishes
C.rectime = 0.5;   %time for recalling an item
C.rstrategy = 1;   %0 = no refreshing during presentation time of items; 1 = use remainder of presentation time of items for refreshing
C.rschedule = 2;   %1 = start over at beginning of list after each operation; 2 = continue after each operation, start at beginning after each new item
                   %3 = start over at beginning but probabilistically

%    cuesim rate ratesd rduration decay threshold noise 
V = [ 0.3   6    1      0.08      0.5    0        0;    % 1: initial model: no threshold, no noise
      0.3   6    1      0.08      0.5    0.1      0;    % 2: model with threshold
      0.3   6    1      0.08      0.5    0        0.02; % 3: model with  noise
      0.3   6    1      0.08      0.5    0.05     0.02; % 4: model with threshold and noise
      0.3   6    1      0.08      0.5    0.05     0.02; % 5: model with threshold and noise SF
      0.3   4    1      0.05      0.5    0.05     0.02]; % 6: row to play around with
  
 % 0.4   6    1      0.08      0.1    0.05     0.1]; 0.3
 % 0.4   3    1      0.08      0.07    0.05     0.1];  
 % 0.3   6    1      0.08      0.15    0.05     0.1]; % little effect in
 % either direction
 % 0.3   4    1      0.08      0.3    0.05     0.03]; % 6: gives a pretty good effect (but too big on immediate)
 %       0.6   6    1      0.08      0.1    0.05     0.02; % 5: model with threshold and noise SF
 
msel =  [6];     %specify one or more models by selecting a row of V parameters

for m = 1:length(msel)
    
    model = msel(m);
    P.cuesim = V(model, 1);
    P.rate = V(model, 2);
    P.ratesd = V(model, 3);
    P.rehduration = V(model, 4);
    P.decay = V(model, 5);
    P.threshold = V(model, 6);
    P.noisefactor = V(model, 7);
    P.rprob = 1;  %default value for refreshing probability
    P.recallrate = -log(1-C.tau)/C.rectime; %computes the recall rate needed to achieve average time of C.rectime
    C.rtau = 1-exp(-P.rate*P.rehduration); %computes the threshold required to ensure that the (average) rehearsal duration = P.rehduration

    if experiment == 1, 
        if grid == 0, GenCspan(model); end
        if grid == 1, GenCspanGrid(model); end
    end
    if experiment == 2, GenBP(model); end
    if experiment == 3, 
        if grid == 0, GenSerialRecall; end
        if grid == 1, GenSerialRecallGrid(model); end
    end
	if experiment == 4, GenM4D; end
	if experiment == 5, GenB04(model); end
	if experiment == 6,
		if grid == 0, GenCspanKids(model); end
		if grid == 1, GenCspanKidsGrid(model); end
	end
	if ismember(experiment, [7,8]), GenCspanTiming(model, experiment); end
	if ismember(experiment, [9,10,11]),
		if grid==0, GenGlobLoc(model, experiment); end
		if grid==1, GenGlobLocGrid(model, experiment); end
	end
    if experiment == 12, GenCspanNOps(model); end

end %for model
