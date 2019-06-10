function axPos = dvAxesPosition(nAxes,margins, optionalInterAxisSpace)
%
% INPUT
%   nAxes: Number of axes to be generated
%   margins: [Left Right Bottom Top]
%
% OUTPUT
%   axPos: Cell array of axes positions in normalized units

%   Created: SRO 4/30/10

if(nAxes == 0)
    warn('dvAxesPosition called for 0 axes');
    axPos = 0;
    return;
end

LeftMargin = margins(1);
RightMargin = margins(2);
BottomMargin = margins(3);
TopMargin = margins(4);

if(~exist('optionalInterAxisSpace'))
    InterAxisSpace = 0.005;
else
    InterAxisSpace = optionalInterAxisSpace;
end

AxisWidth = 1 - LeftMargin - RightMargin;                               
AxisHeight = (1 - BottomMargin - TopMargin - nAxes*InterAxisSpace)/nAxes;


for i = 1:nAxes
    VertLoc = BottomMargin + (nAxes-i)*(AxisHeight+InterAxisSpace);
    axPos{i} = [LeftMargin VertLoc AxisWidth AxisHeight];
end
