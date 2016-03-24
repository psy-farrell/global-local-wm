function out=GenGetsimvec (s, in, modus)
if nargin < 3, modus = 1; end
if modus == 1, keep = rand(1,length(in)) < s; end  %random selection of features to change
if modus == 2, keep = [ones(1,round(length(in)*s)), zeros(1,length(in)-round(length(in)*s))]; end   %selects the first section of proportion s to keep - for rhyming words
% .* does pairwise a1*b1 multiplication
out = keep.*in  + ~keep.*sign(rand(1,length(in))-0.5);
