function x = PostFigure(axiscoords, xlab, ylab, titletext, legendentries, fontsize)
% Formats figure
% arguments: axiscoords: vector of [lower x, upper x, lower y, upper y]
% xlabel, ylabel, title, legendentries (a vector of cells with as many cells as there are data point series)

if nargin < 6, fontsize = 12; end
if nargin < 5, legendentries = []; end
if nargin < 4, titletext = []; end
if nargin < 3, ylab = []; end
if nargin < 2, xlab = []; end

if nargin > 0, axis(axiscoords); end
hx = xlabel (xlab);
hy = ylabel (ylab);
set(gca,'Xcolor','k','Ycolor','k')
if ~isempty(titletext), 
    ht = title (titletext); 
    set(ht, 'Fontsize', fontsize);
end
if ~isempty(legendentries)
    hl=legend (legendentries);  %legendentries must be a cell array of strings
    set(hl, 'TextColor', 'k');
    set(hl, 'EdgeColor', 'k');
    set(hl, 'FontSize', fontsize);
end
set(gca, 'FontSize', fontsize);
set(hx, 'FontSize', fontsize);
set(hy, 'FontSize', fontsize);

plotedit on; %allows manual editing
x=0;

