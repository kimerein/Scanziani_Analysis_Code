function handles = ThreshCallback(hObject,eventdata,handles,UpdateFlag)
%
%
%
%   Created: 4/5/10 - SRO
%   Modified: 7/7 - KR made lines rather than sliders for thresholding

rigdef = RigDefs;
defThresh = rigdef.ExptDataViewer.DefaultThreshold;

if nargin == 3
    UpdateFlag = 1;
end
status = get(hObject,'Value');
if status == 1
    if strcmp(get(hObject,'Enable'),'on')
        set(hObject,'BackgroundColor',[0.3 0.3 1]);       % blue
    end
elseif status == 0
    if strcmp(get(hObject,'Enable'),'on')
        set(hObject,'BackgroundColor',[0.8 0.8 0.8]);
    end
end

% If thresholding has just been turned back on, put line in middle of plot
TglIndex = find(handles.hTglThr == hObject);
dvHandles = guidata(handles.hDataViewer);
ths = get(dvHandles.hThresh(TglIndex),'Ydata');
th = ths(1);
if status == 1 && UpdateFlag~=0
    if strcmp(get(hObject,'Enable'),'on')
        AxisLimits = get(handles.hAllAxes(TglIndex),'YLim');
        % If default threshold is outside axis limits, mean of limits
        if (defThresh > AxisLimits(1)) && (defThresh < AxisLimits(2))
            th = defThresh;
        else
            th = mean(AxisLimits);
        end
    end
end

% Make line threshold vector
handles = MakeThreshVector(handles);
guidata(handles.hPlotChooser,handles);
% Update DataViewer
set(dvHandles.hThresh(TglIndex),'Ydata',th*[1 1]);
UpdateDataViewer(dvHandles);

