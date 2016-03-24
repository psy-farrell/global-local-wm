function cue = GenContext

global E   %experiment parameters
global C   %constants
global P   %model parameters


C.cun = C.cn*E.maxstor;
on(1,:) = round(rand(1, E.maxstor)*C.cn + 0.5);  %uses maxstor to define the number of feature dimensions, and cn to define the different feature values on each dimension
for j = 2:E.maxstor
    change = rand(1,E.maxstor) > P.cuesim;  %selects the active units to be moved
    new = round(rand(1,E.maxstor)*C.cn + 0.5);  %selects their new position
    on(j,:) = (1-change).*on(j-1,:) + change.*new;  %index numbers of the active units
end
cue = zeros(E.maxstor, C.cun);
for j = 1:E.maxstor
    cue(j, (find(on(j,:))-1)*C.cn + on(j,:)) = 1; %switch on the active units
end

P.learnasymptote = 1/sum(cue(1,:)); %each cue element contributes learnrate to each unit of the retrieved content element --> add to 1