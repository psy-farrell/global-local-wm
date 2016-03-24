function align = GenAlign (SP)

global E

if E.distvar == 3
    
    %Global Local 3
    align = zeros(1,4);
    
    for i = 1:E.setsize-1
        if i>1, align(1,1) = align(1,1) + SP(i, i-1); end
        if i<4, align(1,4) = align(1,4) + SP(i, i+2); end
        align(1,2) = align(1,2) + SP(i, i);
        align(1,3) = align(1,3) + SP(i, i+1);
    end
    
    for i = 1:length(align)
        if i == 2 | i ==3, align(1,i) = align(1,i)/(E.setsize-1);
        else
                align(1,i) = align(1,i)/(E.setsize-2);
        end
    end
    
else
    
    % Global Local 1 / 2
    align = zeros(1,3);
    
    for i = 1:E.setsize
        if i>1, align(1,1) = align(1,1) + SP(i, i-1); end
        if i<5, align(1,3) = align(1,3) + SP(i, i+1); end
        align(1,2) = align(1,2) + SP(i, i);
    end
    
    for i = 1:length(align)
        if i == 2, align(1,i) = align(1,i)/E.setsize;
        else
                align(1,i) = align(1,i)/(E.setsize-1);
        end
    end
end