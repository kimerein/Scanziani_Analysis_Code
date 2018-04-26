function [p f] = ComputePower(data,Fs,duration)

N = Fs*duration;            %Number of points
data = data(:,1);
dataf = fft(data);
p = abs(dataf);
p = p/(N/2);                %normalize -- why by 1/2 points
p = p(1:N/2).^2;            % power is squared magnitude. compute for for 1/2 values, the rest are redundant.
f = (0:N/2-1)/duration; 

% figure(10);
% plot(f,p); xlim([0 120]);
% 
% out = p;
% 


