function [ mtarget, breakvar] = aggregate(by, target, aggfun)
%[mtarget, breakvar] = aggregate(by, target, aggfun)
%aggregates like SPSS. 
%Arguments: by = column vector (or matrix) of break variable(s), target = (column) vector or matrix of
%to-be-aggregated variables, by and target must have same vertical size!
%aggfun = function, provided as function handle!
%Output: breakvar = column vector (or matrix) of aggregated break
%variables; mtarget = aggregated variables

if nargin < 3, aggfun = @mean; end

breakvar = unique(by, 'rows');
for a = 1:size(breakvar, 1)
    if size(breakvar,2) == 1, selectedrows = target(by==breakvar(a),:);  %for the case of a single break variable
    else
        sel = ones(size(target,1),1);
        for b = 1:size(breakvar,2)
            sel = sel .* (by(:,b)==breakvar(a,b));
        end
        selectedrows = target(sel==1,:); 
    end
    if size(selectedrows,1) > 1, 
        mtarget(a,:) = aggfun(selectedrows);
    else
        mtarget(a,:) = selectedrows;
    end
end
