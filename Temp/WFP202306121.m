% folder of the data
folder = '\\bigdata\Science\Med\NMS_Prsa\users\Fei\WFacquisition\ACTdiff';
% scan all the data needed
fileList = struct2table(F.FindFiles(folder,{'subgroup','.mat'},{'6-4','7-4'}));
% get the mouseID from filelist.name
fileList.mouseID = cellfun(@(x) str2double(regexp(x,'\d{4}(?=_)','match')),fileList.name,'UniformOutput',true);
% get the groupPairs from filelist.name, eg '2-1'
fileList.groupPairs = cellfun(@(x) regexp(x,'(?<=_)\d-\d','match'),fileList.name,'UniformOutput',true);
% get the subgroupID from filelist.name
fileList.subgroupID = cellfun(@(x) str2double(regexp(x,'(?<=subgroup)\d{1}','match')),fileList.name,'UniformOutput',true);
% subgroupID = subgroupID + 6 if groupPairs = '7-4'
idx = strcmp(fileList.groupPairs,'3-1');
fileList.subgroupID(idx) = fileList.subgroupID(idx) + 4;
% load all the fileList.path
for i = 1:height(fileList)
    F.Progress(i,height(fileList))
    data = load(fileList.path{i});
    sigDiff = FRAMES.ApplyMask(data.meanDiffDeltaFoverF,data.pval<=0.01/(512*512),0);
    fileList.sigDiff{i} = sigDiff(:,:,28);
end

mice = unique(fileList.mouseID);
ncol = length(mice);
subgroup = unique(fileList.subgroupID);
nrow = length(subgroup);
data = cell(nrow,ncol);
for i = 1:ncol
    for j = 1:nrow
        if ~any(fileList.mouseID==mice(i) & fileList.subgroupID==subgroup(j))
            continue
        else
            data{j,i} = fileList.sigDiff{fileList.mouseID==mice(i) & fileList.subgroupID==subgroup(j)};
        end
    end
end
% load ABM template
ABMtemplate = WFA.Load('ABMtemplate');
% number of rows and columns
nRow = size(data,1); nCol = size(data,2); 
% each column is a mouse
mouse = {'M1221','M1222','M1223','M1224','All'}; 
% each row is a session
session = {'R&G(3W)','R&G(4W)','R&G(5W)','R&G(7W)','Wash(2W)','Wash(3W)'};
% add a new column for the average

for i = 1:nRow
    data{i,nCol+1} = mean(cat(3,data{i,1:nCol}),3,'omitnan');
end
% calculate the common colorbar limits
climLow = min(cellfun(@(x) min(x(:),[],'all'), dataMouse),[],'all');
climHigh = max(cellfun(@(x) max(x(:),[],'all'), dataMouse),[],'all');
% keep the colorbar limits symmetric
clim = max(abs(climLow),abs(climHigh));
climLow = -clim; climHigh = clim;

% initialize plot titles
plotTitles = cell(nRow,nCol+1); 
for i = 1:nRow
    for j = 1:nCol+1
        plotTitles{i,j} = [mouse{j} ' ' session{i}];
    end
end
% for each mouse, column, plot the data as a figure
for i = 1:nCol+1
    hfig = figure(i); set(hfig,'Color','w');
    t = tiledlayout(1,6,'TileSpacing','compact','Padding','compact');
    dataMouse = data(:,i);

    % plot each row
    for j = 1:nRow
        % create axes
        ax = nexttile;
        % plot data
        dataTemp = dataMouse{j};
        imagesc(dataTemp);
        % add ABM template
        hold on;
        contour(ABMtemplate, [0.5 0.5], 'Color', 'k', 'LineWidth', 0.05);
        hold off;
        % image axis
        axis image;
        % hide box and x/y axis
        box off; axis off;
        % colormap
        colormap(polarmap);
        % clim
        caxis([climLow climHigh]);
        % title
        title(plotTitles{j,i});
    end
    % add a common colorbar
    c = colorbar('eastoutside');
    c.Label.String = 'diff \DeltaF/F';
    c.Layout.Tile = 'east';
    exportgraphics(gcf,[mouse{i},'.png'],'resolution',300);close(gcf)
end
%% plot the diff deltaFoverF
dataFs1Mask = cellfun(@(X)WFA.ApplyLabelMask(X,26),data,'UniformOutput',false);%[23,25,26,29,30]
meanFs1Diff = cellfun(@(X)mean(X(:),'omitnan'),dataFs1Mask);
% each row is a session， each column is a mouse， plot meanFs1Diff against session
hfig = figure; set(hfig,'Color','w');
plot(meanFs1Diff(:,1),'-o','LineWidth',2,'MarkerSize',3); hold on;
plot(meanFs1Diff(:,2),'-o','LineWidth',2,'MarkerSize',3); hold on;
plot(meanFs1Diff(:,3),'-o','LineWidth',2,'MarkerSize',3); hold on;
plot(meanFs1Diff(:,4),'-o','LineWidth',2,'MarkerSize',3); hold on;
plot(meanFs1Diff(:,5),'-o','LineWidth',2,'MarkerSize',3); hold on;
% legend
legend('M1221','M1222','M1223','M1224','All');
% legend location best
legend('Location','best');
% xticks
xticks(1:5);
% xticklabels
xticklabels({'R&G(3W)','R&G(4W)','R&G(5W)','R&G(7W)','Wash(2W)'});
% xtickangle
xtickangle(45);
% vertical line at x = 6
hLin = xline(4,'--','LineWidth',2);
% hide legend for xline
hAnnotation = get(hLin,'Annotation');
hLegendEntry = get(hAnnotation','LegendInformation');
set(hLegendEntry,'IconDisplayStyle','off');

% flip the y axis
set(gca,'YDir','reverse');
% ylabels
ylabel('diff \DeltaF/F');
% title
title('diff \DeltaF/F, mean of fs1');