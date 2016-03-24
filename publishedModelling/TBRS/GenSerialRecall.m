% Generic WM model applied to Serial Recall

function GenSerialRecall

global E   %experiment parameters
global C   %constants
global P
global M

clear PC; clear MeanPC;
warning('off', 'MATLAB:divideByZero');  %suppresses warnings about division by zero, which occurs frequently during computation of rehearsal accuracy

rand('state',sum(100*clock));  %initializes random generator
randn('state',sum(100*clock)); 

C.rstrategy = 0;  %no rehearsal in between items

%fid = fopen ('GenSspan.out', 'w');

E.enctimes = [0.5, 1];
E.setsize = 7:9;
E.simconds = 1;
E.trialnum = 50;

if E.tracing == 3, E.nreplic = 20; E.setsize = 7; E.trialnum = 50; E.enctimes = 0.5; end

inout = zeros(E.nreplic, length(E.enctimes), max(E.setsize), max(E.setsize), max(E.setsize));
poscorr = zeros(E.nreplic, length(E.enctimes), max(E.setsize), max(E.setsize));
%itemcorr = zeros(E.nreplic, max(E.setsize), max(E.setsize));
%itemrep = zeros(E.nreplic, max(E.setsize), max(E.setsize));

cumtrial = 0;
for id = 1:E.nreplic
  
%Generate vectors for position markers in context layer
M.cue = GenContext;
%Generate the WM stimuli 
M.stim = eye(C.un);

for et = 1:length(E.enctimes)
    E.enctime = E.enctimes(et);
    inoutmatrix = zeros(max(E.setsize), max(E.setsize), max(E.setsize));    

for stor = E.setsize
for trial = 1:E.trialnum
if E.tracing > 0, M.trace = zeros(max(E.setsize), 50); M.probrecall = 0; M.tpos = 1; M.time = 0;  else M.trace = []; M.time = []; end  %initialize trace
cumtrial = cumtrial + 1;

M.w = zeros(C.cun, C.un);  %for hebbian associations to cues - reset for each stimulus set

%Generate list
list = randperm(size(M.stim,1));
list = list(1:stor);

%Encoding 
if ~isempty(M.trace), M = GetTrace(M, P, list, 0); end  %initial state (no time passing, thus 0)
for item = 1:stor
    M.inpos = item;   %records current position in the list
    M.position = item; %records on which position the focus of attention is (for rehearsal)
    GenEncoding(item, list(item), list, tau, C.rate, E.enctime, 1);  
end

%Recall

for probedpos = 1:stor %it is possible to probe for recall in any order, but in complex span, usually recall is in forward order
    M.posfocus = probedpos;
    [recall(probedpos), correct(probedpos), recalltime(cumtrial, probedpos)] = GenRecall(list, probedpos);
end
pc(cumtrial) = mean(correct(1:stor));

%collecting data

for inpos = 1:stor
    for outpos = 1:stor
        if list(inpos) == recall(outpos)
            %itemrecalled(stor,trial,inpos) = itemrecalled(stor,trial,inpos) + 1;  %counts up how often a list item is recalled anywhere
            inoutmatrix(stor,inpos,outpos) = inoutmatrix(stor,inpos,outpos) + 1;
        end
    end
end

end  %trial
inout(id,et,stor,:,:) = inoutmatrix(stor,:,:)./E.trialnum;
poscorr(id,et,stor,:) = diag(squeeze(inout(id,et,stor,:,:)))';
%itemcorr(id,stor,:) = mean(itemrecalled(stor,:,:) > 0);
%itemrep(id,stor,:) = mean(itemrecalled(stor,:,:) > 1);
end  %stor
end  %enctimes
end  %id
Inout = squeeze(mean(inout));
Poscorr = squeeze(mean(poscorr));

if E.tracing < 3

    %plot all serial position curves 
    for et = 1:length(E.enctimes)
    XY = []; 
        for s = E.setsize
            pv(s).x = 1:s;
            pv(s).y = squeeze(Poscorr(et, s, 1:s));
            XY = [XY, 'pv(', mat2str(s), ').x, pv(', mat2str(s), ').y' ];
            if s < max(E.setsize), XY = [XY, ', ']; end
        end
    PreFigure;
    eval(['plot(', XY, ')']);
    title(['Serial Position Curve, Presentation time = ', mat2str(E.enctimes(et))]);
    PostFigure([0, max(E.setsize), 0, 1], 'Serial Position', 'P(recall)');
    end

    %plot input-output-matrix for setsize 6, intermediate encoding time
    PreFigure
    pv = squeeze(Inout(2, 6,1:6,1:6));
    plot(pv');
    legend('inpos1', 'inpos2', 'inpos3', 'inpos4', 'inpos5', 'inpos6'); 
    PostFigure([0, 7, 0, 1], 'Output Position', 'P(recall)');  
    pv

    %plot input-output-matrix for setsize 9, intermediate encoding time
    PreFigure
    pv = squeeze(Inout(2, 9,:,:));
    plot(pv');
    legend('inpos1', 'inpos2', 'inpos3', 'inpos4', 'inpos5', 'inpos6', 'inpos7', 'inpos8', 'inpos9'); 
    PostFigure([0, 10, 0, 1], 'Output Position', 'P(recall)');  

end
