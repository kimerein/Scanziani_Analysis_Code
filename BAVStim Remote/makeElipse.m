function out = makeElipse(rx,ry)
% out =  makeElipse(rx,ry)
% BA

% rx = imageRect(3)/2;
% ry = imageRect(4)/2;

if nargin ==1
    ry = rx;
end
[x,y]=meshgrid([1:rx*2]-rx,[1:ry*2]-ry);


out = sqrt(((x)/rx).^2 + ((y)/ry).^2);
out(find(out<=1 & out>=0))= 1;
out(find(out>1))= 0;



if 0
    imagesc((out))
end