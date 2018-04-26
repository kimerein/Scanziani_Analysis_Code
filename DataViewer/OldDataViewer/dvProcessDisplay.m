function spiketimes = dvProcessDisplay(dv,data,hDataViewer,bExptDataViewer)
% function spiketimes = dvProcessDisplay(dv,data,hDataViewer)
%
% INPUTS
%   dv:
%   data:
%   hDataViewer:
%   varargin{1}: handles
%
% OUTPUT
%   spiketimes:

%   Created: 4/3/10 - SRO
%   Modified: 10/15/10 - SRO


% Get length of data
sizeData = length(data);

% Down-sample data
MaxPoints = 30000;
DownSampFactor = 3;
Fs = dv.Fs;
sizeData = length(data);

if ~bExptDataViewer
    bDownSamp = 1;
    if bDownSamp
        xtime = (1:DownSampFactor:sizeData)*1/Fs;       % sec
        [data Fs] = DownSamp(data,Fs,DownSampFactor);
    else
        xtime = (1:1:sizeData)*1/Fs;
    end
else
    if 0      % Determine whether ExptDataViewer toggle is pushed
        xtime = (1:DownSampFactor:sizeData)*1/Fs;       % sec
        [data Fs] = DownSamp(data,Fs,DownSampFactor);
    else
        xtime = (1:1:sizeData)*1/Fs;
    end
end


if bExptDataViewer % Use only with ExptDataViewer
    h = guidata(hDataViewer);
    h = guidata(h.hPlotChooser);
    bwFilter = get(h.bwFiltToggle,'Value');
    if bwFilter && numel(dv.HPVectorOn ~=0)
        data(:,dv.HPVectorOn) = filtdata(data(:,dv.HPVectorOn),Fs,[],'band',[500 10000],[300 12000]); % Band-pass 0.5-10 kHz
    else
        % Low-pass filter
        if numel(dv.LPVectorOn) ~= 0
            data(:,dv.LPVectorOn) = fftFilter(data(:,dv.LPVectorOn),Fs,dv.LPCutoff(1),1);
        end
        
        % High-pass filter
        if numel(dv.HPVectorOn) ~= 0
            data(:,dv.HPVectorOn) = fftFilter(data(:,dv.HPVectorOn),Fs,dv.HPCutoff(1),2);
            %     data(:,dv.HPVectorOn) = wavefilter(data(:,dv.HPVectorOn),5); %         takes 2-3 times as long but still only 200ms for 4sec
        end
    end
else
    % Low-pass filter
    if numel(dv.LPVectorOn) ~= 0
        data(:,dv.LPVectorOn) = fftFilter(data(:,dv.LPVectorOn),Fs,dv.LPCutoff(1),1);
    end
    
    % High-pass filter
    if numel(dv.HPVectorOn) ~= 0
        data(:,dv.HPVectorOn) = fftFilter(data(:,dv.HPVectorOn),Fs,dv.HPCutoff(1),2);
        %     data(:,dv.HPVectorOn) = wavefilter(data(:,dv.HPVectorOn),5); %         takes 2-3 times as long but still only 200ms for 4sec
    end
end

% Display data
for i = dv.PlotVectorOn'  % Must be row vector for this notation to work
    set(dv.hPlotLines(i),'XData',xtime,'YData',data(:,i));
end

% Make empty spiketimes array
spiketimes = cell(size(data,2),1);
usePeakfinder = getappdata(hDataViewer, 'usePeakfinder');

if numel(dv.RasterVectorOn) ~= 0
    
    for i = dv.RasterVectorOn'     % Must be row vector for this notation to work
        posInd = data(:,i) > 0;
        meanPositive = data(posInd,i);
        meanPositive = mean(meanPositive);
        Threshold = dv.Thresholds(i);
        if usePeakfinder
            [loc] = peakfinder(data(:,i), Threshold*2, dv.Invert(i));
        else
            [loc] = find(dv.Invert(i)*data(:, i) > Threshold); % only detects spikes in the direction of dv.Invert(i) (consistent w/ peakfinder!)
        end
        loc = xtime(loc);
        ylim = get(dv.hAllAxes(i),'YLim');
        pks = loc;
        pks(:) = ylim(2)*0.9;       % y-location of raster is set to 0.95*y-axis max
        set(dv.hRasters(i),'XData',loc,'YData',pks);
        
        % Set spiketimes
        spiketimes{i} = loc;
        
    end
    
end





