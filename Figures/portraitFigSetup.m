function hFig = portraitFigSetup(varargin)

% Created: 10/12/10 - SRO

if nargin > 0 
    hFig = varargin{1};
else
    hFig = [];
end

if ~isempty(hFig)
    hFig = figure(hFig,'Visible','off');
else
    hFig = figure('Visible','off');
end

% Set monitor position of figure
monitorPosition = [444 85 800 1000];

% Set paper position in inches (where figure will be printed on paper)
leftMargin = 0.4;
rightMargin = 0.1;
bottomMargin = 0;
topMargin = 0;
PaperPosition = [leftMargin bottomMargin (8.5-leftMargin-rightMargin) (11-topMargin-bottomMargin) ];

set(hFig,'PaperOrientation','portrait','PaperPosition',PaperPosition, ...
    'Position',monitorPosition,'Color',[0.94 0.94 0.94])

% Get screen size
ScreenSize = get(0,'ScreenSize');

% Make figure visible
set(hFig,'Visible','on')


