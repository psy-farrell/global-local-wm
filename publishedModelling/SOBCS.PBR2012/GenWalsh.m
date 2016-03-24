function W = GenWalsh(n)

numrow = 2;
Wtemp = zeros(n);
W = Wtemp;
W(1,1) = 1;
W(1,2) = 1;
W(2, 1) = 1;
W(2,2) = -1;
    
while (numrow < n)
    k = 1;
    for i = 1:numrow
        for j = 1:numrow
            Wtemp(k,j) = W(i,j);
        end
        k = k+1;
        for (j = 1:numrow)
            Wtemp(k,j) = W(i,j);
        end
        k = k+1;
    end
        
    for (i = 1:(numrow*2))
        for (j = numrow+1:numrow*2)
            if mod(i+1, 2)
                Wtemp(i,j) = Wtemp(i,j-numrow)*-1;
            else
                Wtemp(i,j) = Wtemp(i,j-numrow);
            end
        end
    end
    numrow = numrow * 2;
    W(1:numrow, 1:numrow) = Wtemp(1:numrow, 1:numrow);
end