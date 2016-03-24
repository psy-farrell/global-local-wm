function diff = GenDiff (SP)

global E

if E.distvar == 3
    excptpos = E.setsize - 1;
else
    excptpos = E.setsize;
end

diff = zeros(excptpos, E.setsize);
Cdiff = SP(1,:);
for i = 1:excptpos
    diff(i,:) = SP(i+1,:)-Cdiff;
end