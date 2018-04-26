function data = FilterBlock(data,Fs,high,low)
% filters a block of sweeps using the filterdata function
% data is an MxN matrix, where M is the number of samples and N is the
% number of sweeps. Set filter cut off to zero to suppress high or low pass
% filtering

sweeps = size(data,2);
temp_out = zeros(size(data));

for i = 1:sweeps
    temp = data(:,i);
    if high~=0
        temp = filterdata(temp,1/Fs,high,1);     % high pass
    end
    if low~=0
        temp = filterdata(temp,1/Fs,low,0);   % low pass
    end
    temp_out(:,i) = temp;
end

data = temp_out;


    