function h = updateOnlineSRF(h,spiketimes,matPos)
%
%
%
%
%

% Created:  6/4/10  - SRO
% Modified: 7/21/10 - SRO


% Define window to sum spikes
w = [0.25 1.75];
wspont = [0 0.25];

% Determine number of pixels in image
numPix = h.matrix(1) * h.matrix(2);

% Determine location of stimulus (linear index into matrix defined by h.matrix)
loc = mod(matPos-1,numPix)+1;
[m n] = ind2sub(h.matrix,loc);

for i = 1:size(h.srfData,1)
    % Compute spikes in spont and stimulus windows
    temp = spiketimes{i};
    tempstim = sum((temp >= w(1)) & (temp <= w(2)));
    tempspont = sum((temp >= wspont(1)) & (temp <= wspont(2)));
    
    % Update number of spikes
    h.srfData{i}(m,n,1) = h.srfData{i}(m,n,1) + tempstim;
    h.srfData{i}(m,n,2) = h.srfData{i}(m,n,2) + tempspont;
    
    % Update number of trials
    h.srfData{i}(m,n,3) = h.srfData{i}(m,n,3) + 1;
       
    % Compute evoked rate - spontaneous rate
    temp = (h.srfData{i}(m,n,1)/diff(w) - h.srfData{i}(m,n,2)/diff(wspont))/h.srfData{i}(m,n,3);
    
    % Update pixel
    cMat = get(h.images(i),'CData');
    cMat(loc) = temp;
    
    % Update matrix
    set(h.images(i),'CData',cMat);
    
end
        

