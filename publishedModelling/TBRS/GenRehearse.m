function GenRehearse(availabletime, list, startpos, endpos)
%schedules rehearsal within an interval of free time
%listpos = position of last encoded/next to be retrieved item (needed only for placing rehearsal record)
%startpos = earliest rehearsable position, endpos = last rehearsable position

global M
global C
global P

M.posfocus = startpos;    
while availabletime > 0.01
    response = GenRetrieval(M.posfocus, 0);  %set duration = 0 because decay is modelled during re-encoding; 
    rduration = GenEncoding(M.posfocus, response, list, C.rtau, P.rate, availabletime, 0);   %includes decay of other items during encoding ("duration")
    availabletime = availabletime - rduration;
    M.posfocus = M.posfocus + 1; 
    if M.posfocus > endpos, M.posfocus = startpos; end  %when end of current list reached, go back to beginning and reset record of retrieved items for response suppression
end

