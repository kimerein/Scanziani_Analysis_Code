function handles = HPCallback(hObject,eventdata,handles,UpdateFlag)
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

% Disengage low-pass for selected channel
if isempty(eventdata)
    k = find(hObject == handles.hTglHP);
    set(handles.hTglLP(k),'Value',0);
    eventdata = 1;
    LPCallback(handles.hTglLP(k),eventdata,handles);
end

% Make high-pass vector
handles = MakeHPVector(handles); 
guidata(handles.hPlotChooser,handles);
% Update DataViewer
dvHandles = guidata(handles.hDataViewer); 
UpdateDataViewer(dvHandles);