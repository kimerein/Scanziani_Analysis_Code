function DefineAIChannels(parameters)
% Defines channels in the global object AIOBJ using the cell array
% Parameters.
%
%
% 3/25/10 - SRO
% 4/15/10 - SRO: Added dependence on number of channels on specific nidaq
% board.

global AIOBJ
RigDef = RigDefs;

for i = 1:RigDef.equipment.board.numAnalogInputCh  
    if strcmp(parameters{i,2},'yes')
        hwCh = str2num(parameters{i,4});
        index = str2num(parameters{i,1});
        ch(index) = addchannel(AIOBJ,hwCh,index,parameters{i,3});
        set(ch(index),'InputRange',str2num(parameters{i,5}));
        set(ch(index),'SensorRange',str2num(parameters{i,6}));
        set(ch(index),'Units',parameters{i,8});
    end
end
