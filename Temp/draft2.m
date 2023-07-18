%% Orgnize data
% find all the ATCreg data (8 directions)
infoTableAll = table(); % table to store all the data
for i = 1:8 % 8 directions
    fprintf('Processing direction %d\n',i);
    % get current drive name
    cpath = split(pwd,filesep);
    % add Wfanalysis to the path
    addpath(genpath([cpath{1},'\users\Fei\Code']));
    % get the parameters for the current direction
    p = WF.GetParams(['p_d',num2str(i)],'process',true);
    % find all the ATCreg data for the current direction
    fileList = WFA.GetFileList(p,'ACTreg');
    % load trial information of the current direction
    infoTable = WFA.GetSessionInfo(fileList);
    % add direction information to the table of the current direction
    infoTable.direction = repmat(i,size(infoTable,1),1);
    % concatenate the table of the current direction to the table of all
    infoTableAll = [infoTableAll;infoTable]; %#ok<AGROW>
end

% keep only groupID 4 and 6
infoTableAll = infoTableAll(infoTableAll.groupID==4|infoTableAll.groupID==6,:);
% get the unique groupID
groupIDs = unique(infoTableAll.groupID);
groups = unique(infoTableAll.group);
% struct to store the act data
actData = table(); nActData = 0;
% for each groupIDs (4 and 6)
for i = 1:length(groupIDs)
    cGroupInfoTable = infoTableAll(infoTableAll.groupID==groupIDs(i),:);
    % get the unique mouseIDs
    mouseIDs = unique(cGroupInfoTable.mouseID);
    % for each mouseIDs
    for j = 1:length(mouseIDs)
        cGroupMouseInfoTable = cGroupInfoTable(cGroupInfoTable.mouseID==mouseIDs(j),:);
        % get the unique directions
        directions = unique(cGroupMouseInfoTable.direction);
        % for each direction
        for k = 1:length(directions)
            % increase the counter for actData
            nActData = nActData + 1;
            cGroupMouseDirectionInfoTable = cGroupMouseInfoTable(cGroupMouseInfoTable.direction==directions(k),:);
            % for each item in the table load the data
            frameDir = [];
            for l = 1:height(cGroupMouseDirectionInfoTable)
                fprintf('Loading data %s\n',cGroupMouseDirectionInfoTable.file{l});
                dataTempDir = load(cGroupMouseDirectionInfoTable.file{l});
                frameTemDir = dataTempDir.deltaFoverF(:,:,28);
                frameDir = cat(3,frameDir,frameTemDir);
            end
            % average the data along the third dimension
            frameDirMean = mean(frameDir,3);
            frameDirMeanRegion23 = mean(WFA.ApplyLabelMask(frameDirMean,23),3);
            frameDirMeanRegion25 = mean(WFA.ApplyMask(frameDirMean,25),3);
            frameDirMeanRegion26 = mean(WFA.ApplyMask(frameDirMean,26),3);
            frameDirMeanRegion29 = mean(WFA.ApplyMask(frameDirMean,29),3);
            frameDirMeanRegion30 = mean(WFA.ApplyMask(frameDirMean,30),3);
            frameDirMeanRegionFs1Neighb = mean(WFA.ApplyMask(frameDirMean,[23,25,26,29,30]),3);
            % get the mean of the data along the first dimension
            frameDirMeanRegion23 = mean(frameDirMeanRegion23,[1,2],'omitnan');
            frameDirMeanRegion25 = mean(frameDirMeanRegion25,[1,2],'omitnan');
            frameDirMeanRegion26 = mean(frameDirMeanRegion26,[1,2],'omitnan');
            frameDirMeanRegion29 = mean(frameDirMeanRegion29,[1,2],'omitnan');
            frameDirMeanRegion30 = mean(frameDirMeanRegion30,[1,2],'omitnan');
            frameDirMeanRegionFs1Neighb = mean(frameDirMeanRegionFs1Neighb,[1,2],'omitnan');
            % add the data to the actData
            actData{nActData, 'frames'} = {frameDir};
            actData{nActData, 'frameMean'} = {frameDirMean};
            actData{nActData, 'frameMeanRegion23'} = frameDirMeanRegion23;
            actData{nActData, 'frameMeanRegion25'} = frameDirMeanRegion25;
            actData{nActData, 'frameMeanRegion26'} = frameDirMeanRegion26;
            actData{nActData, 'frameMeanRegion29'} = frameDirMeanRegion29;
            actData{nActData, 'frameMeanRegion30'} = frameDirMeanRegion30;
            actData{nActData, 'frameMeanRegionFs1Neighb'} = frameDirMeanRegionFs1Neighb;
            actData{nActData, 'nFrames'} = size(frameDir,3);
            actData{nActData, 'groupID'} = groupIDs(i);
            actData{nActData, 'group'} = groups(i);
            actData{nActData, 'mouseID'} = mouseIDs(j);
            actData{nActData, 'direction'} = directions(k);
        end
    end
end

%% Plot data
% AMBtemplate
ABMtemplate = WFA.Load('ABMtemplate');
% axes limits for spider plot
frameDirFs1MeanLimits = [repmat(min(actData.frameFs1Mean),1,8); repmat(max(actData.frameFs1Mean),1,8)];
% axes limits for color bar
cLimitsLow = min(cellfun(@(X)min(X,[],'all'),actData.frameMean));
cLimitsHigh = max(cellfun(@(X)max(X,[],'all'),actData.frameMean));
% keep the climits symmetric
cLimits = max(abs(cLimitsLow),abs(cLimitsHigh));
cLimits = [-cLimits,cLimits];
% plot the data for each group and mouse
groupIDs = unique(actData.groupID);
groups = unique(actData.group);
% for each groupIDs (4 and 6)
for i = 1:length(groupIDs)
    cGroupInfoTable = actData(actData.groupID==groupIDs(i),:);
    % get the unique mouseIDs
    mouseIDs = unique(cGroupInfoTable.mouseID);
    % for each mouseIDs
    for j = 1:length(mouseIDs)
        cGroupMouseInfoTable = cGroupInfoTable(cGroupInfoTable.mouseID==mouseIDs(j),:);
        % create a figure for each mouse
        hFig = figure; set(hFig,'Position',[511,76,970,920],'color','w');
        % plot the frameDirFs1Mean for each direction in a polar plot
        t = tiledlayout(3,3); t.TileSpacing = 'compact'; t.Padding = 'compact';
        hAxesPolar = nexttile(5);
        % sort the cGroupMouseInfoTable by direction
        cGroupMouseInfoTable = sortrows(cGroupMouseInfoTable,'direction');
        frameDirFs1Mean = cGroupMouseInfoTable.frameFs1Mean;
        hSp = spider_plot(frameDirFs1Mean',....
            'AxesLimits',frameDirFs1MeanLimits,....
            'AxesWebType', 'circular',....
            'Direction','counterclockwise',....
            'AxesLabels','none');
        % get the unique directions
        directions = unique(cGroupMouseInfoTable.direction);
        % for each direction
        for k = 1:length(directions)
            cGroupMouseDirectionInfoTable = cGroupMouseInfoTable(cGroupMouseInfoTable.direction==directions(k),:);
            % plot the data
            switch k
                case 1
                    hAxes = nexttile(6);
                case 2
                    hAxes = nexttile(3);
                case 3
                    hAxes = nexttile(2);
                case 4
                    hAxes = nexttile(1);
                case 5
                    hAxes = nexttile(4);
                case 6
                    hAxes = nexttile(7);
                case 7
                    hAxes = nexttile(8);
                case 8
                    hAxes = nexttile(9);
            end
            % plot the data
            hMap = imagesc(hAxes,cGroupMouseDirectionInfoTable.frameMean{1});
            % plot the template
            hold on;
            hAMB = contour(ABMtemplate, [0.5 0.5], 'Color', 'k', 'LineWidth', 0.05);
            % set the color limits
            caxis(hAxes,cLimits);
            % set the axes equal
            axis(hAxes,'equal');
            % remove the axes
            axis(hAxes,'off');
            % use polarmap
            colormap(hAxes,polarmap);
            % add title [direction, nFrames]
            title(hAxes,sprintf('D%d, Average of %d sessions',cGroupMouseDirectionInfoTable.direction(1),cGroupMouseDirectionInfoTable.nFrames(1)));
        end
        % add colorbar common to all the tiles
        cb = colorbar;cb.Layout.Tile = 'east';
        % add title to the figure
        title(t,sprintf('%s, M%d',groups{i},mouseIDs(j)));
        % save the figure as a png
        exportgraphics(hFig,sprintf('%s_M%d.png',groups{i},mouseIDs(j)));
    end
end

%% Plot difference between groups

% split the data into two groups
base = actData(actData.groupID==4,:);
train = actData(actData.groupID==6,:);
% join the actDataGroup4 and actDataGroup6 into one table by mouseID and direction
actDataPair = join(base,train,'Keys',{'mouseID','direction'});
% calculate the difference of frame between the two groups
actDataPair.frameDiff = cellfun(@(X,Y)X-Y,actDataPair.frameMean_train,actDataPair.frameMean_base,'UniformOutput',false);
% load the template
ABMtemplate = WFA.Load('ABMtemplate');
% axes limits for spider plot
frameDirFs1MeanMax = max([actDataPair.frameFs1Mean_base,actDataPair.frameFs1Mean_train],[],'all');
frameDirFs1MeanLimits = [zeros(1,8); repmat(frameDirFs1MeanMax,1,8)];
% axes limits for color bar
cLimitsLow = min(cellfun(@(X)min(X,[],'all'),actDataPair.frameDiff));
cLimitsHigh = max(cellfun(@(X)max(X,[],'all'),actDataPair.frameDiff));
% keep the climits symmetric
cLimits = max(abs(cLimitsLow),abs(cLimitsHigh));
cLimits = [-cLimits,cLimits];
% plot the data for each mouse
mouseIDs = unique(actDataPair.mouseID);
% for each mouseIDs
for j = 1:length(mouseIDs)
    cMouseActDataPair = actDataPair(actDataPair.mouseID==mouseIDs(j),:);
    % create a figure for each mouse
    hFig = figure; set(hFig,'Position',[511,76,970,920],'color','w');
    % plot the frameDirFs1Mean for each direction in a polar plot
    t = tiledlayout(3,3); t.TileSpacing = 'compact'; t.Padding = 'compact';
    hAxesPolar = nexttile(5);
    % sort the cMouseActDataPair by direction
    cMouseActDataPair = sortrows(cMouseActDataPair,'direction');
    frameDirFs1MeanBase = cMouseActDataPair.frameFs1Mean_base';
    frameDirFs1MeanTrain = cMouseActDataPair.frameFs1Mean_train';
    hSp = spider_plot([frameDirFs1MeanBase;frameDirFs1MeanTrain],....
        'AxesLimits',frameDirFs1MeanLimits,....
        'AxesWebType', 'circular',....
        'Direction','counterclockwise',....
        'AxesLabels','none');
    legend('baseline', 'intensiveTraining', 'Location', 'southoutside');
    legend('boxoff')
    % get the unique directions
    directions = unique(cMouseActDataPair.direction);
    % for each direction
    for k = 1:length(directions)
        cMouseDirectionActDataPair = cMouseActDataPair(cMouseActDataPair.direction==directions(k),:);
        % plot the data
        switch k
            case 1
                hAxes = nexttile(6);
            case 2
                hAxes = nexttile(3);
            case 3
                hAxes = nexttile(2);
            case 4
                hAxes = nexttile(1);
            case 5
                hAxes = nexttile(4);
            case 6
                hAxes = nexttile(7);
            case 7
                hAxes = nexttile(8);
            case 8
                hAxes = nexttile(9);
        end
        % plot the data
        hMap = imagesc(hAxes,cMouseDirectionActDataPair.frameDiff{1});
        % plot the template
        hold on;
        hAMB = contour(ABMtemplate, [0.5 0.5], 'Color', 'k', 'LineWidth', 0.05);
        % set the color limits
        caxis(hAxes,cLimits);
        % set the axes equal
        axis(hAxes,'equal');
        % remove the axes
        axis(hAxes,'off');
        % use polarmap
        colormap(hAxes,polarmap);
        % add title [direction, nFrames]
        title(hAxes,sprintf('D%d',cMouseDirectionActDataPair.direction(1)));
    end
    % add colorbar common to all the tiles
    cb = colorbar;cb.Layout.Tile = 'east';
    % add title to the figure
    title(t,sprintf('Diff, M%d',mouseIDs(j)));
    % save the figure as a png
    exportgraphics(hFig,sprintf('diff_M%d.png',mouseIDs(j)));
end