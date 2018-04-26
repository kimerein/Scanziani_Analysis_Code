 function stimConds = readDigitalPorts(diobj,Trigger,TriggerRepeat,LoggingMode,LogFileName)
% function readDigitalPorts(obj,event,diobj)
% read digital object diobj and save to disk.
persistent CondNum SaveName

temp = getvalue(diobj);
stimcond = bin2dec(num2str(temp(end:-1:1)));


if Trigger == 1;
    CondNum = [];
    SaveName = LogFileName(1:end-4);
    CondNum = nan(2,TriggerRepeat+1);  % declare variable
end
CondNum(:,Trigger) = [now stimcond];
if strcmp(LoggingMode, 'Disk&Memory')
    save([SaveName '_TrigCond'],'CondNum');
end
stimConds = CondNum;


