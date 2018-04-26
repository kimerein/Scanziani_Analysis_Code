function pavg(expt,channels,bOR,varargin)



[data xtime] = avg(expt,channels,bOR,varargin{1},varargin{2});
plot(xtime,data)

% figure(999)
% cmap = colormap(jet);
% for i = 1:size(data,2)
%     line('XData',xtime,'YData',data(:,i),'Color',cmap(randint(1,1,64),:));
% end