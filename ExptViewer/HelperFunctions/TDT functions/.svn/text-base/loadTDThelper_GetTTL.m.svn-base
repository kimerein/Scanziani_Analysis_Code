function bTTL = loadTDThelper_getTTL(blkPATH,EPOCNAME,EPOCNAMELIGHT,bsave)
% function bLight = loadTDThelper_getTTL(blkPATH,EPOCNAME,EPOCNAMELIGHT,bsave)
% find EPOCNAME epocs when TTL transitioned to high
filename = loadTDThelper_makefilename(blkPATH);

if nargin<2 || isempty(EPOCNAME); EPOCNAME = 'Vcod'; end;
if nargin<3 || isempty(EPOCNAMELIGHT); EPOCNAMELIGHT = 'Ligh'; end;
if nargin <4; bsave = 1; end

if isempty(dir(fullfile(blkPATH,[filename '_' EPOCNAMELIGHT 'Cond.*'])))
    temp = loadTDThelper_getEpocVal(blkPATH,EPOCNAME);
    tempL = loadTDThelper_getEpocVal(blkPATH,EPOCNAMELIGHT);
    
    temp = temp([2 3],:);
    tempL = tempL([2 3],:);
    lenVstim = min(diff(temp(:,1:end-1))); % length of Vstim Epoc
                                           % skip last sweep it is possible that last TTL never went low
    bTTL = zeros(1,size(temp,2));
    for i = 1:size(temp,2)
        D = tempL(1,:) - temp(1,i);
        if any(D>0 & D<lenVstim) % find cases where TTL goes high during a Vstim
            bTTL(i) = 1;
        end
    end
    if bsave;                save(fullfile(blkPATH,[filename,'_' EPOCNAMELIGHT 'Cond']),'bTTL');    end
    
else
    filename = regexprep(filename,'%%','%%%'); % to support % in filename
    load(fullfile(blkPATH,sprintf('%s_%sCond',filename,EPOCNAMELIGHT)),'bTTL');
end