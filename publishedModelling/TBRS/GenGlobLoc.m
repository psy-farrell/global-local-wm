% TBRS model applied to Global Local experiments

function GenGlobLoc(model, experiment)

global E   %experiment parameters
global C   %constants
global P   %model parameters
global M   %record of memory states

warning('off', 'MATLAB:divideByZero');  %suppresses warnings about division by zero, which occurs frequently during computation of rehearsal accuracy

rand('state',sum(100*clock));  %initializes random generator
randn('state',sum(100*clock));

E.distvar = experiment-8; %model 9 = GL1, 10 = GL2, 11 = GL3
E.setsize = 5;
E.trialnum = 10;
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

fid = fopen ('TBRS.GlobLoc.out', 'w');

SP1 = zeros(E.nreplic, ncond, E.setsize); %Serial position store
SP2 = zeros(E.nreplic, ncond, E.setsize); %Serial position store

for id = 1:E.nreplic
    
    id
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
                
                %saving data
                fprintf (fid, '%3.0f %2.0f %1.2f %1.2f %1.0f %1.0f %1.2f   %1.2f %1.2f %1.2f %1.2f %1.2f %1.4f   %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f   %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f   %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f \n', ...
                    id, model, E.opduration(1), E.freetime(1), E.opnum(1), E.setsize, P.cuesim, ...
                    P.rate, P.ratesd, P.rehduration, P.decay, P.threshold, P.noisefactor, ...
                    correct, list9, recall);
                
            end  %trial
            
            %locposx = localpos+1;
            if globloc == 1, SP1(id,exceptpos,:) = mean(Serpos, 1);
            else
                SP2(id,exceptpos,:) = mean(Serpos, 1);
            end
            
            if E.tracing == 1
                PreFigure(1, [], 2);
                plot(M.time, M.trace(:,1:M.tpos-1)');
                titletext = (['condition = ', mat2str(exceptpos)]);
                PostFigure([], 'Time (s)', 'Strength', titletext, [], 12);
                correct(1:E.setsize)
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
    
    MSP1 = squeeze(mean(SP1,1));
    Mrecall(1,:) = MSP1(1,:);
    Mrecall(2,:) = mean((MSP1(2:end,:)),1);
    Diff1 = GenDiff (MSP1)
    DAlign(1,:) = GenAlignSF(Diff1);
    
    
    if E.distvar ==3
        
        PreFigure(1,[],3);
        plot(Mrecall');
        legend(recallegtext(3:4));
        title(['Recall probability across exception conditions']);
        PostFigure([0, E.setsize+1, 0, 1], 'Serial Position', 'P(recall)');
        %PostFigure('auto', 'Serial Position', 'P(recall)');
        Mrecall
        
        PreFigure(1,[],3);
        plot(MSP1');
        legend(splegtext(1:ncond));
        title(['Recall probability for ', recallegtext{4}]);
        PostFigure([0, E.setsize+1, 0, 1], 'Serial Position', 'P(recall)');
        %PostFigure('auto', 'Serial Position', 'P(recall)');
        MSP1
        
        
        PreFigure(1,[],3);
        plot(DAlign');
        legend(alignlegtext(1:E.maxglbcond));
        title(['Difference aligned around exception position']);
        PostFigure([0, 5, -0.5, 0.5], 'Exception Position', 'P(diff)');
        %PostFigure('auto', 'Exception Position', 'P(diff)');
        DAlign
        
    else
        
        MSP2 = squeeze(mean(SP2,1));
        Mrecall(3,:) = MSP2(1,:);
        Mrecall(4,:) = mean((MSP2(2:end,:)),1);
        Diff2 = GenDiff (MSP2);
        DAlign(2,:) = GenAlignSF(Diff2);
        
        PreFigure(1,[],3);
        plot(Mrecall');
        legend(recallegtext(1:4));
        title(['Recall probability across exception conditions']);
        PostFigure([0, E.setsize+1, 0, 1], 'Serial Position', 'P(recall)');
        %PostFigure('auto', 'Serial Position', 'P(recall)');
        Mrecall
        
        PreFigure(1,[],3);
        plot(MSP1');
        legend(splegtext(1:ncond));
        title(['Recall probability for ', recallegtext{2}]);
        PostFigure([0, E.setsize+1, 0, 1], 'Serial Position', 'P(recall)');
        %PostFigure('auto', 'Serial Position', 'P(recall)');
        MSP1
        
        PreFigure(1,[],3);
        plot(MSP2');
        legend(splegtext(1:ncond));
        title(['Recall probability for ', recallegtext{4}]);
        PostFigure([0, E.setsize+1, 0, 1], 'Serial Position', 'P(recall)');
        %PostFigure('auto', 'Serial Position', 'P(recall)');
        MSP2
        
        
        PreFigure(1,[],3);
        plot(-4:4, DAlign');
        legend(alignlegtext(1:E.maxglbcond));
        title(['Difference aligned around exception position']);
        PostFigure([-5, 5, -0.4, 0.4], 'Exception Position', 'P(diff)');
        %PostFigure('auto', 'Exception Position', 'P(diff)');
        DAlign
    end
    
    %inoutmatrix = disp(bsxfun(@rdivide, inoutmatrix, sum(inoutmatrix,2)));
    
    figure
    for kk=1:6
        subplot(2,3,kk)
        plot(inoutmatrix(:,:,kk)')
    end
    
    
    fclose(fid);
    
    figure
    plot(ommcurve(1:6,:)')
    
    MSP1
    ommcurve./E.nreplic
    intcurve./E.nreplic
    
    figure
    plot(intcurve(1:6,:)')
end



end