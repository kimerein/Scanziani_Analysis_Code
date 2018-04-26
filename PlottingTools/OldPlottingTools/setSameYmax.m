function ymax = setSameYmax(hAxes,percent,setmin)
% function setSameYmax(hAxes)
% Finds max y-value of lines across a group of axes, and sets all axes to
% the same max.
%
% INPUT
%   hAxes: Vector of axes handles
%   percent: Percent of axis above max point
%   setmin: Flag determining whether minium is to 0 (setmin = 0), or the
%   minium across all lines (setmin = 1).

% Created: 5/13/10 - SRO

if nargin < 2
    percent = 0;
    setmin = 0;
end

if nargin < 3
    setmin = 0;
end

h = findobj(hAxes,'Type','line');

ymax(1)=0.00001;
ymin(1)=0;
for i = 1:length(h)
    temp = get(h(i),'YData');
    if ~isempty(temp)
        ymax(i) = max(temp);
        ymin(i) = min(temp);
    end
end

ymax = max(ymax) + max(ymax)*percent/100;
ymin = min(ymin) + min(ymin)*percent/100;
if ~setmin
    ymin = 0;
end
if ~isnan(ymax) && ~(ymax == 0)
    set(hAxes,'YLim',[ymin ymax]);
else
    set(hAxes,'YLim',[0 1]);
end
    