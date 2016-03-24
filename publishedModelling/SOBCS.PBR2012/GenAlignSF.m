function align = GenAlignSF (SP)

global E

if E.distvar == 3
    
    %Global Local 3
    lags = -(E.setsize-2):(E.setsize-1);
    lagi=1;
    for tlag = lags
        align(lagi) = mean(diag(SP,tlag));
        lagi=lagi+1;
    end
    
%     error('Not set up to do this');
%     align = zeros(1,4);
%     
%     for i = 1:E.setsize-1
%         if i>1, align(1,1) = align(1,1) + SP(i, i-1); end
%         if i<4, align(1,4) = align(1,4) + SP(i, i+2); end
%         align(1,2) = align(1,2) + SP(i, i);
%         align(1,3) = align(1,3) + SP(i, i+1);
%     end
%     
%     for i = 1:length(align)
%         if i == 2 | i ==3, align(1,i) = align(1,i)/(E.setsize-1);
%         else
%                 align(1,i) = align(1,i)/(E.setsize-2);
%         end
%     end
    
else
    
    % Global Local 1 / 2
    lags = -(E.setsize-1):(E.setsize-1);
    lagi=1;
    for tlag = lags
        align(lagi) = mean(diag(SP,tlag));
        lagi=lagi+1;
    end
    
end