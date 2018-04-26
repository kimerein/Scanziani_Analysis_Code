function varargout = ToolBarIcons(varargin)
% TOOLBARICONS M-file for ToolBarIcons.fig
%      TOOLBARICONS, by itself, creates a new TOOLBARICONS or raises the existing
%      singleton*.
%
%      H = TOOLBARICONS returns the handle to a new TOOLBARICONS or the handle to
%      the existing singleton*.
%
%      TOOLBARICONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TOOLBARICONS.M with the given input arguments.
%
%      TOOLBARICONS('Property','Value',...) creates a new TOOLBARICONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ToolBarIcons_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ToolBarIcons_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ToolBarIcons

% Last Modified by GUIDE v2.5 16-Dec-2009 08:02:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ToolBarIcons_OpeningFcn, ...
                   'gui_OutputFcn',  @ToolBarIcons_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before ToolBarIcons is made visible.
function ToolBarIcons_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ToolBarIcons (see VARARGIN)

% Choose default command line output for ToolBarIcons
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ToolBarIcons wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ToolBarIcons_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function lowPass_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to lowPass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


a = 'wait for it'
