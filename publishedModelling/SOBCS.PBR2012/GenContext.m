function context = GenContext(cuesim, n)

global E   %experiment parameters
global C   %constants

if nargin < 2, n = max(E.setsize); end

cun = C.cun;
detas = ones(1, n);
walshmatrix = GenWalsh(cun)';
context = zeros(n, cun);

for i=1:n
    for j=1:cun
        if i==1
            context(i,j) = walshmatrix(i,j);
        else
            for k=1:i
                context(i,j) = context(i,j) + detas(k) * walshmatrix(k,j);
            end
        end
    end
    
    context(i,:) = GenNormvec(context(i,:)')' .*sqrt(cun);
    for j=1:i
        detas(j) = detas(j) * cuesim;
    end
    detas(i+1) = sqrt(1 - (cuesim * cuesim));
end

