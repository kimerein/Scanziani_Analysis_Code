function plotCSD()

cd('C:\SRO DATA\Data\RawData\Filtered')

plots = [1];
numPlots = numel(plots);

% Find min and max across all CSDs
for i = 1:numPlots
    FileName = ['CSDblockInd' num2str(plots(i))];
    load(FileName);
    tempMax = max(max(dataInt));
    tempMin = min(min(dataInt));
    if i == 1
        fMax = tempMax;
        fMin = tempMin;
    end
    fMax = max([fMax tempMax]);
    fMin = min([fMin tempMin]);
%     allCSD(:,:,i) = dataInt(:,0.1*4000:0.5*4000);
end

% % Compute pixel-by-pixel correlation
%   mCSD = mean(allCSD(:,:,end-2:end),3);
% 
% for i = 1:numPlots
%     FileName = ['CSDblockInd' num2str(plots(i))];
%     load(FileName);
%     dataInt = allCSD(:,:,i);
%     dataInt = reshape(dataInt,numel(dataInt),1);
%     if i == 1
%         bVector = reshape(mCSD,numel(dataInt),1);
%     end
%     temp = corr([dataInt bVector]);
%     allCorrCoef(i) = temp(2);
% end

% figure(3); plot(plots,allCorrCoef,'-o');

FileName = ['CSDblockInd' num2str(plots(i))];
load(FileName);
% % fMax = fMax*0.5;
% fMin = fMin*0.5;
dt = size(dataInt,2);
dt = 3/dt;
xdata = 0:dt:3-dt;

% % Compute mean CSD and plot difference
% figure(2);
% subplot(3,1,1); m1 = mean(allCSD(:,:,1:3),3);
% imagesc(m1,'XData',xdata); caxis([fMin fMax]);
% subplot(3,1,2); m2 = mean(allCSD(:,:,end-3:end),3);
% imagesc(m2,'XData',xdata); caxis([fMin fMax]);
% subplot(3,1,3); m = m2-m1;
% imagesc(m,'XData',xdata); 


% Plot all CSDs
hplot = figure(1);
for i = 1:numPlots
    FileName = ['CSDblockInd' num2str(plots(i))];
    load(FileName);
    subplot(numPlots,1,i);
    imagesc(dataInt,'XData',xdata); caxis([fMin fMax]);
    drawnow
end
