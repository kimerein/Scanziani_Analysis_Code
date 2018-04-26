function handles = LPCallback(hObject,eventdata,handles,UpdateFlag)
%
%
%
%   Created: 4/5/10 - SRO
%   Modified:

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

% Disengage high-pass for selected channel
if isempty(eventdata)
    k = find(hObject == handles.hTglLP);
    set(handles.hTglHP(k),'Value',0);
    eventdata = 1;
    HPCallback(handles.hTglHP(k),eventdata,handles);
end

% Make low-pass vector
handles = MakeLPVector(handles);
% Update handles for PlotChoosder
guidata(handles.hPlotChooser,handles);
% Update DataViewer
dvHandles = guidata(handles.hDataViewer); 
UpdateDataViewer(dvHandles);