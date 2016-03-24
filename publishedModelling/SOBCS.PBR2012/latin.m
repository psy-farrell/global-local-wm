function m = latin(n)

m = zeros(n);
for i=1:n
    for j=1:n
        m(i,j) = mod(i + j - 1, n) + 1;
    end
end