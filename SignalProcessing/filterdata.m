function prodata = filterdata(data,dt,cutoff,type)
% function prodata = filterdata(data,dt,cutoff,type)
% Function filters data 
% INPUT:  
%     data-    matrice of data.
%     dt -    sampling (used to turn cutoff into appropriate frequency)
%     cutoff - "cut off frequency" (Hz)
%     type - 0 = low-pass, 1 = high-pass
%     
% OUTPUT:
%     prodata
%
% BA103006
% if ~isrowvector(data) % catches the case of column vector having been input instead or row vector
%     if size(data,2) ==1
%         data = data';
%     end
% end
if type ==0 
    stype = 'low';
elseif type ==1
    stype = 'high';
else
    error('Unknown fiter type')
end
tic
[B,A] = butter(2,2*cutoff*dt,stype);
toc
prodata =   filtfilt(B,A,data);