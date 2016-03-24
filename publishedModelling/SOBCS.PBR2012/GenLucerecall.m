function [response, responsevector] = GenLucerecall

global M
global P

[voj, confidence] = GenLuce;         %computes the normalised similarity of the retrieved vector to all item vectors
voj = cumsum(voj);     %cumulative sum of similarities to calculate intervals between values, increased probability of selecting higher value
x = rand;              %generate random values between 0 - 1 for item selection process
r = min(find(x<voj));  %selection of a candidate for recall dependent on interval in which x falls
response = M.recallset(r);
responsevector = M.candidates(r,:); 
if confidence < P.threshold
    response = -4;
end

%embedded function
function [voj, confidence] = GenLuce

global M
global P

dists = zeros(1, size(M.candidates,1));
for i = 1:size(M.candidates,1)
    dists(i) = (sum((M.wm - M.candidates(i,:)).^2))^.5;  %Euclidean distance between retrieved item and all item vectors
end
dists = dists - min(dists);
s = exp(-P.c * dists.^2);
S = sort(s, 'descend');
conflict = 0;
if P.threshold > 0
    for a = 1:length(S)
        for b = 1:length(S)
            if a ~= b, conflict = conflict + S(a)*S(b); end
        end
    end
    confidence = 1/conflict;
else confidence = 1;
end
denom = sum(s);
voj = s./denom;