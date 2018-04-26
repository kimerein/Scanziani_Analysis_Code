function data = zeroTrace(data,window,Fs)


pts = round(window*Fs + 1);
meanWindow = mean(data(pts(1):pts(2)));
data = data - meanWindow;