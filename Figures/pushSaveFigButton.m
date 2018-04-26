function pushSaveFigButton(hSaveFigTool)
% function pushSaveFigButton(hSaveFigTool)
%
%

% Created: SRO - 5/24/11


temp = get(hSaveFigTool,'ClickedCallback');
fh = temp{1};
feval(fh,hSaveFigTool,[],temp{2:end});
