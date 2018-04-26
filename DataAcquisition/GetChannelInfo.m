function handles = GetChannelInfo(handles)
global AIOBJ
handles.Channel = get(AIOBJ,'Channel');
handles.nActiveChannels = length(handles.Channel);