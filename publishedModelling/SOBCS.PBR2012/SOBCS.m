% Wrapper for SOB-CS (Stripped-down version corresponding to publication)

clear all;    close all

global E   %experiment parameters
global C   %constants
global P   %model parameters
global M   %memory contents
global O   %output

% ----------------------------

% *** define experimental paradigm test number ***

simulation = 12;

% SIMULATION NUMBER DEFINITIONS:
% 1 = Simulation 1 (CL and Nops);  
% 2 = Simulation 2 (Decomposing CL); 
% 3 = Simulation 3 (Nops, distractor variability, serial position curves, item and order errors); 
% 4 = Simulation 4: Item-Distractor Similarity by Proximity
% 5 = Simulation 5: Item-Distractor Categorical Similarity 
% 6 = Simulation 6: Cross-domain interference
% 7 = Simulation 7: Individual Differences 
% 8 = Serial recall with manipulation of similarity

% 10 = GL 1
% 11 = GL2
% 12 = GL3

% {>>SF 27/06/13: Can't simulate Gl2 easily, as energy calculation is f'ed up by zeros in distractors (ie they look more novel) <<}
% Could be solved by normalizing logistic to number of expected elements,
% but too much work to make the point

% General experimental parameters (common to all simulations) and parameters for controlling simulation
E.maxstor = 9;       %maximum list length (for span procedure) 
E.plotting = 3;      %0 = none, 1 = minimalist, 2 = more (depending on experiment), 3 = yet more
E.serposval = 7;     %list length for serial position curve plots
E.nreplic = 200;     %number of subjects simulated (or N trials for globlocgrid)

%Constants
C.sim = [0.50, 0.65]; %similarity between dissimilar items/ similar items (for words; for letters, sim is directly derived from the MDS solution; digits use C.sim(1))
C.itemdistsim = 0.35;  % similarity of distractor items to list items when they come from different categories
C.cuesim = 0.5;    %similarity (= degree of overlap) of positional cues
C.rectime = 1.0;   %time for recalling an item
C.un = 150;        %number of units for item layer
C.offun = 150;	   %set C.offun:C.un units to zero in distractors (used for type)
C.cun = 16;        %number of units for position layer

%Parameters for different model configurations 

%   rset thresh  no   c    rate rrate tau   gain   
V = [2   0     1.50  1.30  6   1.5  -1000  0.0033];

model = 1;

P.recallset = V(model, 1);       %1 = only list items, 2 = whole item vocabulary, 3 = list items plus distractors, 4 = whole item vocabulary plus distractors
P.threshold = V(model, 2);       %retrieval threshold
P.nsubo = V(model, 3);           %Noise weighting on item-context representations = output interference
P.c = V(model, 4);               %Weights Euclidean distance in Luce 
P.rate = V(model, 5);            %rate of encoding
P.removalrate = V(model, 6);     %rate of removal 
P.tau = V(model, 7);             %shift of logistic for computation of strength from Energy
P.gain = V(model, 8);            %gain of logistic for computation of strength from Energy

if simulation == 1, GenCspan(model); end
if simulation == 2, GenOpdurFreetime; end
if simulation == 3, GenDistVar(model); end
if simulation == 4, GenItemDistSim(model); end
if simulation == 5, GenCspanCatSim(model); end
if simulation == 6, GenCspanDomains(model); end
if simulation == 7, GenKane04; end
if simulation == 8, GenSerialRecall(2); end  %argument = stimulus category, 1 = digits, 2 = letters, 3 = words (nonrhyming sim), 4 = words (rhyming sim)
if simulation > 8
	%GenGlobLoc(model,simulation)
	GenGlobLocGrid(model,simulation)
end
