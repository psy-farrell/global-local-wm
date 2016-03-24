function energy = GenEnergy(i, item)

global M

t = M.cue(i,:) * M.w;
energy = t * -item';
