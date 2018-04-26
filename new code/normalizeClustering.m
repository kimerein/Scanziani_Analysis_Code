
normX=X(:,1:end);
% 
normX(:,1)=normX(:,1)./normX(:,4);
normX(:,9)=normX(:,9)./normX(:,4);
% normX(:,1)=normX(:,1)./normX(:,4);
%normX(:,8)=normX(:,8)./normX(:,3);
for i=1:size(normX,2)
    normX(:,i)=normX(:,i)/(max(abs(normX(:,i))));
end

% normX=X(:,[1:2 4:end]);

% normX(:,1)=normX(:,1)./normX(:,4);
% normX(:,8)=normX(:,8)./normX(:,4);
% normX(:,1)=normX(:,1)./normX(:,4);
% normX(:,8)=normX(:,8)./normX(:,3);
% for i=1:size(normX,2)
%     normX(:,i)=normX(:,i)/(max(abs(normX(:,i))));
% end

k=5;
normclus=kmeans(normX,k,'replicates',200);
figure();
scatter(X(:,9)./X(:,4),X(:,1)./X(:,4),[],normclus);
xlabel('fractional reb');
ylabel('fractional sup');
figure();
scatter(X(:,4),X(:,1)./X(:,4),[],normclus);
xlabel('vis');
ylabel('fractional sup');
% figure();
sil=silhouette(normX,normclus);
display(mean(sil));

% figure();
% %scatter(X(currNormclus==1,9)./X(currNormclus==1,4),X(currNormclus==1,1)./X(currNormclus==1,4));
% scatter(X(currNormclus==1,9)./X(currNormclus==1,4),X(currNormclus==1,1)./X(currNormclus==1,4));
% hist(X(normclus==1,1)./X(normclus==1,4),4);
% figure();
% %scatter(X(currNormclus==2,9)./X(currNormclus==2,4),X(currNormclus==2,1)./X(currNormclus==2,4));
% hist(X(normclus==2,1)./X(normclus==2,4),8);
% figure();
% %scatter(X(currNormclus==3,9)./X(currNormclus==3,4),X(currNormclus==3,1)./X(currNormclus==3,4));
% hist(X(normclus==3,1)./X(normclus==3,4),5);
% figure();
% hist(X(normclus==4,1)./X(normclus==4,4),4);
% figure();
% hist(X(normclus==5,1)./X(normclus==5,4),4);
% figure();
% hist(X(normclus==6,1)./X(normclus==6,4),5);
% figure();
% hist(X(normclus==7,1)./X(normclus==7,4),4);