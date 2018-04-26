function data = prepdata (data,bplot,dt,dfilter)
% function data = prepdata (data,bplot,dt,dfilter) OR
% function data = prepdata (data,bplot,dt,dfilter (structure) )
%
% Preprocess data (detrend) >200
% so that there is little drift in baseline to allow effective thresholding
% of currents
%
% INPUT :
%          data:  if 2D: each ROW should contain one sweep or channel
%                 if 3D each ROW is timeseries, will loop through all
%                 ROW and PAGE.
%          dfilter =[HIGH_PASS_Hz LOW_PASS_Hz  60Hz_removal bdetrend]
%                   e.g. [20 200 0 0] bandpass 20-200 and no 60Hz removal,
%                   no detrend
%                        [NaN NaN 1]  finds significant peaks (determined by hard-coded p-value) and subtracts
%                        them, detrend
%                        [NaN NaN 40 1] removes significant peak at 40Hz
%                        (note: for all  60Hz_removal values >0 and not
%                        equal to 1,  signifiant power at THAT frequency
%                        is removed, detrend
%   OR 
%         dfilter.filttype = 1 for filtering with butterworth
%                          = 2 for fft (Throw away unwanted frequencies)
%         df - (optional) pass in variable that will be used for
%         filtered data in order to save memory using matlab's "in-place"
%         function operations
% OUTPUT:
%         df = N by M row. Where N is the sweep/channels and M is the
%         timeseries. i.e. each row is a timeseries
% BA061407
sp = 'y';

if nargin < 3
    dt = 1;
end
if nargin < 2
    bplot = 1;
end
if bplot ==0
    sp = 'n';
end

if ~isstruct(dfilter)
if length(dfilter)< 4 % for backwards compatibility
    dfilter(4) = 1;
end
filttype = 1; % use filterdata function
else
    if isfield(dfilter,'filttype')
        filttype = dfilter.filttype;
    else
        filttype = 1;
    end
    dfilter = dfilter.dfilter;
end
    

h = NaN;k=1;
Nsweeps = size(data,2);
Npages = size(data,3);
hRmline = []
for j = 1:Npages
    if dfilter(4)
        if abs(mean(data(:,1,j))/20)<std(data(:,1,j)) % don't actually run detrend unless mean is large compared to std
            % this is a bit of a wierd thing to do, can take it out later, but helps with memory not to run detrend 
            display('DETREND NOT run because mean is SMALL')
        else data(:,:,j) = detrend(squeeze(data(:,:,j))); end
            
    end
    for i = 1:Nsweeps
        
    if dfilter(3)
        params.Fs = 1/dt;
        params.fpass =  [1 100];
        params.tapers = [3 5];
        params.pad = 2;
        %         params.err = [1 fs/0.500];
        %         params.f0 = [];
        p = 5/size(data,2);
        %     p = [];
        %         f0 = [60]; %[60 88]
        if dfilter(3) == 1; f0 = []; else f0 = dfilter(3); end
        
        if ~isempty(f0);
            for j = 1:length(f0) % allows for multiple f0s but there is NO way to specify them when calling the function
                [data(:,i,j) hRmline(k)] =     rmlinesc(squeeze(data(:,i,j)),params,p,sp,f0(j));
                k =k+1;
            end
        else
            k =1;
            [data(:,i,j) hRmline(k)] =     rmlinesc(squeeze(data(:,i,j)),params,p,sp,f0);
        end
        if ~isempty(hRmline)
            set(hRmline,'Tag','PLOT_rmline');
        end
    end
    % TODO should make into bandpass instead of low and hig pass
    switch filttype
        case 1
            if ~isnan(dfilter(1))&(dfilter(1)>0)
                data(:,i,j) = filterdata(squeeze(data(:,i,j)),dt,dfilter(1),1);
            end
            if ~isnan(dfilter(2))
                data(:,i,j) = filterdata(squeeze(data(:,i,j)),dt,dfilter(2),0);
            end
        case 2 % use fftfilter
            if ~isnan(dfilter(1))&(dfilter(1)>0)
                data(:,i,j)= fftFilter(squeeze(data(:,i,j))',1/dt,dfilter(1),2)';
            end
            if ~isnan(dfilter(2))
                data(:,i,j)= fftFilter(squeeze(data(:,i,j))',1/dt,dfilter(2),1)';
            end          
    end
end

if bplot
    display('no longer supported')
%     t = 5;% time in sec
%     sw = 1; % if more than 1 sw/episode only plot first
%     h=figure;
%     clf
%     plotdata(detrend(squeeze(data(:,sw,j)),'constant')',dt,'trange',[0 t],'fid',h);
%     hold all
%     plotdata(squeeze(df(:,sw,j))',dt,'trange',[0 t],'fid',h);
%     set(h,'Position',[7   538   560   420]);
%     % plotdata(df+std(df)*5,dt,'trange',[0 t],'fid',1)
else
    if ~isnan(h); close(h); end
end

end


data = squeeze(data);