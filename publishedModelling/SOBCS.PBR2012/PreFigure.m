function x = PreFigure(new, re, style)
%first argument: new (0 = overwrite old figure, 1 = create new figure, 2 = add to existing figure)
%second argument: re = placement rectangle [left, bottom, width, height],
%scaled from 0 to 1
%third argument: style (1 = black/white, with points, 2 = colour, just lines, 3 = colour, with points, 4 = color, only points)

if nargin < 1 || isempty(new), new = 1; end  %default: create new figure (rather than overwriting old one)
if nargin < 2 || isempty(re), re = [0.1,0.1,0.8,0.8]; end %left, bottom, width, height
if nargin < 3, style = 1; end  %default: black/white
if new == 0,
    hold off;
end
if new == 1,
    figure;
    axes ('position', re);     %Places axes at 'position'
end
if new == 2,
    hold on;
end

% first remove old color and linestyle orders

set(gcf,'DefaultAxesLineStyleOrder','remove');
set(gcf,'DefaultAxesColorOrder','remove');

if style == 1
    set (gcf, 'DefaultAxesLineStyleOrder', {'-*','-s','-o', '-v', '-x',':*',':s', ':o', ':v', ':x'});
    set (gcf, 'DefaultAxesColorOrder', [0,0,0])
end
if style == 2
    set (gcf, 'DefaultAxesLineStyleOrder', {'-','--',':','-.'});
    set (gcf, 'DefaultAxesColorOrder', [0,0,0; 1,0,0; 0,1,0; 0,0,1; 0.5,0.5,0; 0,0.5,0.5; 0.5,0,0.5]);
    % color varies faster than linestyle, and all colors are plotted with
    % the first linestyle before moving on to the second linestyle
end
if style == 3
    set (gcf, 'DefaultAxesLineStyleOrder', {'-*','-s','-x',':x',':*',':s'});
    set (gcf, 'DefaultAxesColorOrder', [0,0,0; 1,0,0; 0,1,0; 0,0,1; 0.5,0.5,0; 0,0.5,0.5; 0.5,0,0.5]);
end
if style == 4
    set (gcf, 'DefaultAxesLineStyleOrder', {'o'});
    set (gcf, 'DefaultAxesColorOrder', [0,0,0; 1,0,0; 0,1,0; 0,0,1; 0.5,0.5,0; 0,0.5,0.5; 0.5,0,0.5]);
end

set (0, 'Defaultfigurecolor', 'k')
set(0, 'DefaultTextColor', 'k')
set (gcf, 'Color','w')
set (gca, 'box', 'on')
x=0;

