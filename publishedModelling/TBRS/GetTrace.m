function M = GetTrace(M, P, list, elapsedtime)
stor = length(list);
a = zeros(1,stor);  %initialize activation
for p = 1:stor  %for all positions
    for c = 1:stor  %for all items in list, compute activation, given position probe p
        %a(c) = sum((M.cue(p,:)*M.w).*M.stim(list(c),:))./sum(M.stim(list(c),:));
        r = (M.cue(p,:)*M.w);  %retrieves stimulus vector by cueing with position, and goes on to retrieve focus vector
        a(c) = r(list(c));  %activation of list item in position c according to the retrieval process in the preceding line
    end
    M.trace(p, M.tpos) = a(p);  %pick activation of item p
end
if M.tpos == 1, M.time = elapsedtime; else M.time(M.tpos) = M.time(M.tpos-1) + elapsedtime; end
M.tpos = M.tpos + 1;  %for next trace

 
