% TBRS model applied to Complex Span experiment varying operation duration
% and free time independently (not in PB&R publication)

function GenM4D

global E   %experiment parameters
global C   %constants
global P   %model parameters
global M   %record of memory states
global O   %outcome variables for plotting

warning('off', 'MATLAB:divideByZero');  %suppresses warnings about division by zero, which occurs frequently during computation of rehearsal accuracy

rand('state',1235);  %initializes random generator
randn('state',1235); 

% Experimental parameters
      
Ter = 0.1:0.1:0.8;           %assumed time for sensory-motor component in RTs that does not require the bottleneck
    Ter = 0.5;                   % default assumed time
Decay = 0.2:0.05:0.55;       %decay values corresponding to Ter values (needed to adjust accuracy)
    Decay = 0.15;                 %reduced decay to see whether that helps TBRS
    P.rate = 2;                  %reduced rate to compensate for reduced decay
E.opnum = 4;                 %number of operations following each item
E.enctime = 1.0;             %presentation time for an item 
E.setsize = [5,4,5];         %set sizes for the 3 experiments
E.trialnum = 20; 

for nondecisiontime = 1:length(Ter)
ter = Ter(nondecisiontime);
P.decay = Decay(nondecisiontime);

Opdurations1 = [1.21, 1.45;
                1.39, 1.56;
                1.38, 1.56] - ter;  %observed mean times for doing easy/hard processing in first within-burst position
Opdurations24 = [0.89, 1.09;
               1.02, 1.18;
               1.03, 1.19] - ter; %observed mean times for doing easy/hard processing step in positions 2-4 in each burst
E.freetime = [0.2, 0.8]+ter;      %free times after each operation

O.SP = zeros(size(Opdurations1,1), length(E.freetime), size(Opdurations1,2), max(E.setsize)); 

for exprm = 1:size(Opdurations1,1);

E.serposval = E.setsize(exprm);
stor = E.setsize(exprm);
PC = zeros(E.maxstor, E.trialnum);  %initialize percent-correct
Serpos = zeros(E.trialnum, max(E.setsize)); %initialize serial-position variable 
O.Serpos = zeros(E.nreplic, length(E.freetime), size(Opdurations1,2), max(E.setsize)); 

for id = 1:E.nreplic
 
%Generate vectors for position markers in context layer
M.cue = GenContext;   
     
%Generate the WM stimuli 
M.stim = eye(C.un);

for od = 1:size(Opdurations1,2)
for ot = 1:length(E.freetime)
for trial = 1:E.trialnum
if E.tracing > 0, M.trace = zeros(stor, 50); M.probrecall = 0; M.tpos = 1; M.time = 0; else M.trace = []; M.time = []; end  %initialize trace

M.w = zeros(C.cun, C.un);  %for hebbian associations to cues - reset for each stimulus set

%Generate list
list = randperm(size(M.stim,1));
list = list(1:stor);

%Encoding and processing of distractors
if ~isempty(M.trace), M = GetTrace(M, P, list, 0); end  %initial state (no time passing, thus 0)
for item = 1:stor
    M.inpos = item;   %records current position in the list
    M.posfocus = item; %records on which position the focus of attention is (for refreshing)
    GenEncoding(item, list(item), list, C.tau, P.rate, E.enctime, 1);  
    M.posfocus = 1; 
    for op = 1:E.opnum
        if op == 1, E.opduration = Opdurations1(exprm,:); else E.opduration = Opdurations24(exprm,:); end
        E.oprate = -log(1-C.tau)./E.opduration; %convert mean operation times into mean rates
        GenProcess(list, od, ot); 
    end
end

%Recall

correct = zeros(1,max(E.setsize));               %initialize correctness scoring of individual items
for probedpos = 1:stor %it is possible to probe for recall in any order, but in complex span, usually recall is in forward order
    M.posfocus = probedpos;
    [recall(probedpos), correct(probedpos)] = GenRecall(list, probedpos);  
end

%collecting data
PC(stor,trial) = mean(correct(1:stor));
Serpos(trial, :) = correct;

end  %trial

O.Serpos(id, ot, od, :) = mean(Serpos);

end  %ot
end  %od
end  %id

O.SP(exprm,:,:,:) = mean(O.Serpos,1); %indices: expm, freetime, opduration, setsize
O.pcdesign(exprm,:,:) = squeeze(mean(O.SP(exprm,:,:,1:stor),4)); %means of the 2x2 design
pcezh = squeeze(mean(O.SP(exprm,:,:,:),2));    %means of ez (1st row) and hard (2nd row) operations for all serial positions (columns)
O.ezheffect(exprm,:) = pcezh(1,:) - pcezh(2,:);
pcfreetime = squeeze(mean(O.SP(exprm,:,:,:),3));  %means of short (1st row) and long (2nd row) free times for all serial positions (columns)
O.freetimeeffect(exprm,:) = pcfreetime(2,:) - pcfreetime(1,:); %accuracy at long minus short free time
O.decaytimediff = (stor:-1:1).*E.opnum.*(E.opduration(2)-E.opduration(1));
if stor < max(E.setsize), O.decaytimediff = [O.decaytimediff, zeros(1,max(E.setsize)-stor)]; end  %padding
O.TLS(exprm,:) = O.ezheffect(exprm,:)./O.decaytimediff;           %time-loss slopes (as in Oberauer & Lewandowsky, 2008, PsychReview)
O.EZHeffect(exprm, nondecisiontime) = mean(O.ezheffect(exprm,:)); %averaging across serial positions
O.ratio(exprm, nondecisiontime) = mean(O.ezheffect(exprm,:)) ./ mean(O.freetimeeffect(exprm,:)); %ratio of ezh-effect to freetime effect (separate for each experiment)

end  %exprm

%plot 2x2 design effects 
PreFigure;
for exprm = 1:size(Opdurations1,1)
    x = ((exprm-1)*2 + 1):exprm*2;
    plot(x, squeeze(O.pcdesign(exprm,:,:)));
    hold on
end
title(['Ter = ', mat2str(ter)]);
legend('short ops', 'long ops');
PostFigure([0.5, exprm*2+0.5, 0, 1], 'Experiment and Free Time'); 

if ter == 0.5  %only plot and save data for Ter of most interest
   
    for i = 1:length(E.freetime)
        freetimelegtext{i} = [mat2str(E.freetime(i)), ' s'];
    end
    for i = 1:length(E.opduration)
        opdurationlegtext{i} = [mat2str(E.opduration(i)), ' s'];
    end

    %plot SPCs for Experiments 1 and 3 (leaving out E2 because it had only 4
    %items)
    PreFigure;
    plot(squeeze(mean(mean(O.SP([1,3],:,:,:),1),3))');  %leaving dimension 2 = freetime
    legend(freetimelegtext(1:length(E.freetime)));
    title(['Serial Position Curve & Free Time']);
    PostFigure([0, 6, 0, 1], 'Serial Position', 'P(recall)');    

    PreFigure;
    plot(squeeze(mean(mean(O.SP([1,3],:,:,:),1),2))');  %leaving dimension 3 = opduration
    legend(opdurationlegtext(1:length(E.opduration)));
    title(['Serial Position Curve & Operation Duration']);
    PostFigure([0, 6, 0, 1], 'Serial Position', 'P(recall)');      

    %write into file: ez.short, hard.short, ez.long, hard.long
    fid = fopen('tbrs.m4d.dat', 'w');
    for exprm = 1:size(Opdurations1,1)
        fprintf(fid, '%2.4f, %2.4f, %2.4f, %2.4f \n', O.pcdesign(exprm,1,1), O.pcdesign(exprm,1,2), O.pcdesign(exprm,2,1), O.pcdesign(exprm,2,2));
    end
    fclose(fid); 

end

end