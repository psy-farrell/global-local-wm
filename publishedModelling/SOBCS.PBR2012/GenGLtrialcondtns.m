function trialconds = GenGLtrialcondtns

global E %experiment parameters

condtnno = E.setsize+1;

if E.distvar ~= 3
    trialconds = [repmat(1, condtnno, E.setsize);
                  repmat(2, condtnno, E.setsize)];
              
    for h = 1:E.maxglbcond
        for i = 2:condtnno
            if h==1
                trialconds(((h-1)*condtnno)+i,i-1) = 2;
            else
                trialconds(((h-1)*condtnno)+i,i-1) = 1;
            end
        end
    end
else
    trialconds = [repmat(2, E.setsize, E.setsize)];    
    for i = 2:E.setsize
            trialconds(i,i-1:i) = 1;
    end
end  