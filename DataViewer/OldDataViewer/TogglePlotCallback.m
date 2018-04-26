function handles = TogglePlotCallback(hObject,handles)
%
%
%
%   Created: 4/5/10 - SRO
%   Modified:

status = get(hObject,'Value');
if status == 1
    set(hObject,'BackgroundColor',[0.2 0.2 1]);       % blue
    TglIndex = find(handles.hTglPlotAll == hObject);
    if get(handles.hTglLP(TglIndex),'Value') == 1
        set(handles.hTglLP(TglIndex),'Enable','on','BackgroundColor',[0.2 0.2 1]);
    else
        set(handles.hTglLP(TglIndex),'Enable','on','BackgroundColor',[0.8 0.8 0.8]);
    end
    if get(handles.hTglHP(TglIndex),'Value') == 1
        set(handles.hTglHP(TglIndex),'Enable','on','BackgroundColor',[0.2 0.2 1]);
    else
        set(handles.hTglHP(TglIndex),'Enable','on','BackgroundColor',[0.8 0.8 0.8]);
    end
    if get(handles.hTglThr(TglIndex),'Value') == 1
        set(handles.hTglThr(TglIndex),'Enable','on','BackgroundColor',[0.2 0.2 1]);
    else
        set(handles.hTglThr(TglIndex),'Enable','on','BackgroundColor',[0.8 0.8 0.8]);
    end
elseif status == 0
    set(hObject,'BackgroundColor',[0.8 0.8 0.8]);
    TglIndex = find(handles.hTglPlotAll == hObject);
    set(handles.hTglLP(TglIndex),'Value',0,'Enable','off','BackgroundColor',[0.925 0.914 0.847]);
    set(handles.hTglHP(TglIndex),'Value',0,'Enable','off','BackgroundColor',[0.925 0.914 0.847]);
    set(handles.hTglThr(TglIndex),'Value',0,'Enable','off','BackgroundColor',[0.925 0.914 0.847]);
    handles = LPCallback(handles.hTglLP(TglIndex),1,handles,0);
    handles = HPCallback(handles.hTglHP(TglIndex),1,handles,0);
    handles = ThreshCallback(handles.hTglThr(TglIndex),[],handles,0);
end

% Make plot vectors
handles = MakePlotVector(handles); 
guidata(handles.hPlotChooser,handles);
% Update DataViewer
dvHandles = guidata(handles.hDataViewer);
UpdateDataViewer(dvHandles);