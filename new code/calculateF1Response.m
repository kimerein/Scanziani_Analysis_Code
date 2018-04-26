function F1=calculateF1Response(spikes,cycPerSec,bin,window,integratePowerWindow)

a=unique(spikes.assigns);
F1=zeros(length(a),1);
for i=1:length(a)
    noLED=filtspikes(spikes,0,'assigns',a(i),'led',0);
    noLED_FRs=[];
    Fs=1/bin;
    for j=0:bin:window(2)-window(1)
        if window(1)+j+bin>window(2)
            break
        else
            noLED_FRs=[noLED_FRs sum(((noLED.spiketimes>window(1)+j) + (noLED.spiketimes<window(1)+j+bin))-1)/length(unique(noLED.trials))];
        end
    end
%     F1powRatio=getPowerAtFreq(Fs,noLED_FRs,cycPerSec,integratePowerWindow);
%     F1(i)=F1powRatio;
    F1mod=getAmpAtFreq(Fs,noLED_FRs,cycPerSec,integratePowerWindow);
    F1(i)=F1mod;
end

function powRatio=getPowerAtFreq(Fs,x,freq,integratePowerWindow)
% % Time vector of 1 second 
% t = 0:1/Fs:1; 
% 
% % Create a sine wave of 200 Hz.
% x = sin(2*pi*t*200); 

% Use next highest power of 2 greater than or equal to length(x) to calculate FFT.
nfft= 2^(nextpow2(length(x))); 

% Take fft, padding with zeros so that length(fftx) is equal to nfft 
fftx = fft(x,nfft); 

% Calculate the numberof unique points
NumUniquePts = ceil((nfft+1)/2); 

% FFT is symmetric, throw away second half 
fftx = fftx(1:NumUniquePts); 

% Take the magnitude of fft of x and scale the fft so that it is not a function of the length of x
mx = abs(fftx)/length(x); 

% Take the square of the magnitude of fft of x. 
mx = mx.^2; 

% Since we dropped half the FFT, we multiply mx by 2 to keep the same energy.
% The DC component and Nyquist component, if it exists, are unique and should not be multiplied by 2.
if rem(nfft, 2) % odd nfft excludes Nyquist point
  mx(2:end) = mx(2:end)*2;
else
  mx(2:end -1) = mx(2:end -1)*2;
end

% This is an evenly spaced frequency vector with NumUniquePts points. 
f = (0:NumUniquePts-1)*Fs/nfft; 

lessThanInds=find(f<integratePowerWindow(1));
lowerInd=lessThanInds(end);
upperInd=find(f>integratePowerWindow(2),1);
powRatio=mean(mx(lowerInd:upperInd))/mx(1);
% Generate the plot, title and labels. 
% plot(f,mx); 
% title('Power Spectrum of a Average Response to Stimulus'); 
% xlabel('Frequency (Hz)'); 
% ylabel('Power');

function ampRatio=getAmpAtFreq(Fs,x,freq,integratePowerWindow)
%     bandPassSignal=fftFilter(x,Fs,integratePowerWindow(2),1);
%     bandPassSignal=fftFilter(bandPassSignal,Fs,integratePowerWindow(1),2);

nfft= 2^(nextpow2(length(x))); 

X = fft(x,nfft); % compute Fourier transform
n = size(x,2)/2; % 2nd half are complex conjugates
amp_spec = abs(X)/n; % absolute value and normalize
NumUniquePts = ceil((nfft+1)/2);
amp_spec = amp_spec(1:NumUniquePts); 
f = (0:NumUniquePts-1)*Fs/nfft;

% figure(); 
% plot(f,amp_spec); % plot amplitude spectrum
% xlabel('Frequency (Hz)'); % 1 Herz = number of cycles/second
% ylabel('Amplitude');

lessThanInds=find(f<integratePowerWindow(1));
lowerInd=lessThanInds(end);
upperInd=find(f>integratePowerWindow(2),1);
ampRatio=mean(amp_spec(lowerInd:upperInd))/amp_spec(1);
