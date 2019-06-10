function varargout = GUI_listFilesVisualParams(varargin)
%GUI_LISTFILESVISUALPARAMS M-file for GUI_listFilesVisualParams.fig
%      GUI_LISTFILESVISUALPARAMS, by itself, creates a new GUI_LISTFILESVISUALPARAMS or raises the existing
%      singleton*.
%
%      H = GUI_LISTFILESVISUALPARAMS returns the handle to a new GUI_LISTFILESVISUALPARAMS or the handle to
%      the existing singleton*.
%
%      GUI_LISTFILESVISUALPARAMS('Property','Value',...) creates a new GUI_LISTFILESVISUALPARAMS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to GUI_listFilesVisualParams_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      GUI_LISTFILESVISUALPARAMS('CALLBACK') and GUI_LISTFILESVISUALPARAMS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in GUI_LISTFILESVISUALPARAMS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_listFilesVisualParams

% Last Modified by GUIDE v2.5 14-Apr-2010 20:47:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_listFilesVisualParams_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_listFilesVisualParams_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI_listFilesVisualParams is made visible.
function GUI_listFilesVisualParams_OpeningFcn(hObject, eventdata, handles, varargin)

% set default returned value to empty
setappdata(0,'ListDialogAppData__',[]);


if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'exptstruct'
          handles.expt =  varargin{index+1};
         case 'fileind'
          handles.fileInd = varargin{index+1};
        end
    end
end


expt = handles.expt;
fileInd = handles.fileInd ;
% fill up the list
set(handles.listbox,'String',expt.files.names(fileInd));
% fill Table
for i = 1:length(fileInd)
    varparam = expt.stimulus(i).varparam;
    nvar = length(varparam);
    for j = 1:nvar
        tabledata{i,(j-1)*2+1} = varparam(j).Name;
        tabledata{i,(j-1)*2+2} = num2str(varparam(j).Values,'%1.3g ');
    end
end

set(handles.VarParamTable,'Data',tabledata);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_listFilesVisualParams wait for user response (see UIRESUME)
try
    % Give default focus to the listbox *after* the figure is made visible
    uicontrol(handles.listbox);
    uiwait(handles.figure1);
catch
    if ishghandle(handles.figure1)
        delete(handles.figure1)
    end
end


% --- Outputs from this function are returned to the command line.
function varargout = GUI_listFilesVisualParams_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = getappdata(0,'ListDialogAppData__');



% --- Executes on selection change in listbox.
function listbox_Callback(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox


% --- Executes during object creation, after setting all properties.
function listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% get selected files
selectedfileInd = handles.fileInd(get(handles.listbox,'value'));
setappdata(0,'ListDialogAppData__',selectedfileInd);

% Update handles structure
guidata(hObject, handles);
delete(handles.figure1);


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
close(handles.figure1);

% --- Executes on button press in selectall_btn.
function selectall_btn_Callback(hObject, eventdata, handles)
% hObject    handle to selectall_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'enable','off')
set(handles.listbox,'value',1:length(get(handles.listbox,'string')));


% --- Executes when user attempts to close figure1.
% function figure1_CloseRequestFcn(hObject, eventdata, handles)
% % hObject    handle to figure1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: delete(hObject) closes the figure
% delete(hObject);
