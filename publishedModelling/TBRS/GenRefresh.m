function GenRefresh(availabletime, list, startpos, endpos)
%schedules rehearsal within an interval of free time
%listpos = position of last encoded/next to be retrieved item (needed only for placing rehearsal record)
%startpos = earliest rehearsable position, endpos = last rehearsable position

global M
global C
global P

if C.rschedule == 1, M.posfocus = startpos; end
if C.rschedule == 3
    pstart = pdf('exp', [startpos:endpos], 2);  %exponential distribution of P(start) over list positions
    cumpstart = cumsum(pstart./sum(pstart));  
    startpos = find(cumpstart > rand, 1);
end

while availabletime > 0.01
    refresh = rand < P.rprob;  %decision whether refreshing occurs at all
    if refresh
        response = GenRetrieval(M.posfocus, 0);  %set duration = 0 because decay is modelled during re-encoding; 
        %correctrehearsal = response == list(M.posfocus); 
        rduration = GenEncoding(M.posfocus, response, list, C.rtau, P.rate, availabletime, 0);   %includes decay of other items during encoding ("reduration"-->"encduration")
    else  %if failure to refresh, time still passes
        r = max(0.1, P.rate + randn*P.ratesd);  %random variation of rate 
        rduration = min(availabletime, -log(1-C.rtau)/r);  %solving the exponential growh function for time after setting strength = tau --> actual encoding time until tau is reached
        M.w = M.w * exp(-P.decay*rduration);  %decay during the time of passivity
    end
    availabletime = availabletime - rduration;
    M.posfocus = M.posfocus + 1; %move on to next list position
    if M.posfocus > endpos, M.posfocus = startpos; end  %when end of current list reached, go back to beginning and reset record of retrieved items for response suppression
end

