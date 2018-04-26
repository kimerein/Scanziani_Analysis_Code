% script for making clusters

% highlyF1mod=X(:,3)>0.1;
% fat=X(:,6)>5.5*10^-4;
% colors=zeros(size(X,1),1)+highlyF1mod+2*fat-(highlyF1mod&fat);

% stronglySup=X(:,1)>1;
% stronglyFac=X(:,1)<-0.4;
% reallyFat=X(:,6)>=6*10^-4;
% colors=zeros(size(X,1),1)+stronglySup+2*stronglyFac+3*reallyFat;

% stronglySup=X(:,1)>0.7;
% stronglyFac=X(:,1)<-0.3;
%stronglySup=(X(:,1)>0.6)&(X(:,5)>0.4);
% stronglySup=(X(:,1)>0.6)&(X(:,6)>0.4*10^-4);

stronglySup=(X(:,6)>2.4*10^-4);

%stronglySup=(X(:,8)>0.34*10^-3)&(X(:,6)>4*10^-4)&(X(:,1)>0);
%stronglyFac=(X(:,1)<-0.2)&(X(:,2)<1)&(X(:,8)<0.4);
% stronglyFac=(X(:,1)<-0.2)&(X(:,6)<0.55*10^-4);

%RGC=(X(:,1)>0);
RGC=(X(:,6)<2.4*10^-4)&(X(:,1)>0);

% stronglyFac=(X(:,8)<0.5*10^-3)&(X(:,6)<2.8*10^-4)&(X(:,3)<0.08);
stronglyFac=(X(:,6)<2.4*10^-4)&(X(:,1)<=0);
reallyFat=X(:,6)>=6*10^-4;
% colors=zeros(size(X,1),1)+stronglySup+2*stronglyFac+3*reallyFat;
%colors=zeros(size(X,1),1)+stronglySup+2*stronglyFac;
colors=zeros(size(X,1),1);
colors(stronglySup&~stronglyFac)=3;
colors(stronglyFac&~stronglySup)=1;
colors(RGC&~stronglySup&~stronglyFac)=5;
colors(reallyFat)=2;
%colors=zeros(size(X,1),1)+stronglySup+2*stronglyFac;

figure();
scatter(X(:,3)./X(:,4),X(:,6),[],colors);
xlabel('F1/vis');
ylabel('halfwidth');

figure();
scatter(X(:,6),X(:,7),[],colors);
xlabel('halfwidth');
ylabel('amp');
figure();
scatter(X(:,6),X(:,1)./X(:,4),[],colors);
xlabel('halfwidth');
ylabel('fractional sup');

figure();
scatter(X(:,9)./X(:,4),X(:,1)./X(:,4),[],colors);
xlabel('fractional reb');
ylabel('fractional sup');

figure();
[n1,xout1]=hist(X(colors==1,1),5);
% const=1/max(n1);
% n1=n1*const;
hold on;
[n2,xout2]=hist(X(colors==2,1),20);
const=1/max(n2);
n2=n2*const;
[n3,xout3]=hist(X(colors==3,1)./X(colors==3,4),20);
% const=1/max(n3);
% n3=n3*const;
bar(xout1',n1');
figure();
bar(xout3',n3');
