mice =  {'1221','1222','1223','1224'};

for j = 1:length(mice)
% load the data
load(['\\bigdata\Science\Med\NMS_Prsa\users\Fei\WFacquisition\ACTdiff\',mice{j},'_2-1.mat']);

% set the non-significant pixels to 0
sigFrame = FRAMES.ApplyMask(meanDiffDeltaFoverF,pval<=0.01,0);
% generate time vector
Tpre = 1; Tpost = 1.5; Fs = 20; Ts = 1/Fs;
time = [-Tpre:Ts:-Ts 0 Ts:Ts:Tpost];
idx = time >= -0.50 & time <= 0.95;
% plot the data within the window
time = time(idx); sigFrame = sigFrame(:,:,idx);
% calculate the color map limits
climLow = min(sigFrame(:));
climHigh = max(sigFrame(:));
% keep the color map symmetric
climSym = max(abs(climLow),abs(climHigh)); 
clim = [-climSym climSym];
% create tile for subplots based on time
titleStr = cell(1,length(time));
for i = 1:length(time)
    titleStr{i} = sprintf('%.2f s',time(i));
end

FRAME.ShowMulti(sigFrame,'colormap',polarmap,'title',titleStr,'clim',clim,'clabel','diff \DeltaF/F')

suptitle(['M',mice{j}])
% maximize the figure to fit the screen
set(gcf,'Position',get(0,'Screensize'))
exportgraphics(gcf,[mice{j},'vibrationNCP.png'],'Resolution',300)
end

%%
mice =  {'1221','1222','1223','1224'};

for j = 1:length(mice)
% load the data
load(['\\bigdata\Science\Med\NMS_Prsa\users\Fei\WFacquisition\ACTdiff\',mice{j},'_2-1.mat']);

% set the non-significant pixels to 0
sigFrame = FRAMES.ApplyMask(meanDiffDeltaFoverF,pval<=0.01/(512*512),0);
% generate time vector
Tpre = 1; Tpost = 1.5; Fs = 20; Ts = 1/Fs;
time = [-Tpre:Ts:-Ts 0 Ts:Ts:Tpost];
idx = time >= -0.50 & time <= 0.95;
% plot the data within the window
time = time(idx); sigFrame = sigFrame(:,:,idx);
% calculate the color map limits
climLow = min(sigFrame(:));
climHigh = max(sigFrame(:));
% keep the color map symmetric
climSym = max(abs(climLow),abs(climHigh)); 
clim = [-climSym climSym];
% create tile for subplots based on time
titleStr = cell(1,length(time));
for i = 1:length(time)
    titleStr{i} = sprintf('%.2f s',time(i));
end

FRAME.ShowMulti(sigFrame,'colormap',polarmap,'title',titleStr,'clim',clim,'clabel','diff \DeltaF/F')

suptitle(['M',mice{j}])
% maximize the figure to fit the screen
set(gcf,'Position',get(0,'Screensize'))
exportgraphics(gcf,[mice{j},'vibration.png'],'Resolution',300)
end
%%
climLow = zeros(1,length(mice)); climHigh = zeros(1,length(mice));
for j = 1:length(mice)
% load the data
load(['\\bigdata\Science\Med\NMS_Prsa\users\Fei\WFacquisition\ACTdiff\',mice{j},'_6-4.mat']);

% set the non-significant pixels to 0
sigFrame = FRAMES.ApplyMask(meanDiffDeltaFoverF,pval<=0.01/(512*512),0);

climLow(j) = min(sigFrame(:));
climHigh(j) = max(sigFrame(:));
end

for j = 1:length(mice)
% load the data
load(['\\bigdata\Science\Med\NMS_Prsa\users\Fei\WFacquisition\ACTdiff\',mice{j},'_2-1.mat']);

% set the non-significant pixels to 0
sigFrame = FRAMES.ApplyMask(meanDiffDeltaFoverF,pval<=0.01/(512*512),0);
% generate time vector
Tpre = 1; Tpost = 1.5; Fs = 20; Ts = 1/Fs;
time = [-Tpre:Ts:-Ts 0 Ts:Ts:Tpost];
idx = time >= -0.50 & time <= 0.95;
% plot the data within the window
time = time(idx); sigFrame = sigFrame(:,:,idx);
% calculate the color map limits
climLow = min(climLow(:));
climHigh = max(climHigh(:));
% keep the color map symmetric
climSym = max(abs(climLow),abs(climHigh)); 
clim = [-climSym climSym];
% create tile for subplots based on time
titleStr = cell(1,length(time));
for i = 1:length(time)
    titleStr{i} = sprintf('%.2f s',time(i));
end

FRAME.ShowMulti(sigFrame,'colormap',polarmap,'title',titleStr,'clim',clim,'clabel','diff \DeltaF/F')

suptitle(['M',mice{j}])
% maximize the figure to fit the screen
set(gcf,'Position',get(0,'Screensize'))
exportgraphics(gcf,[mice{j},'vibrationSameScale.png'],'Resolution',300)
end
