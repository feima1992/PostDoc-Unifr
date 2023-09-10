function ActRoi_PlotAvgFrawDiffMeanTuning(obj, options)
% validate inputs
arguments
    obj
    options.roiId (1,:) double = 1:size(obj.ActRoi.mask.raw.rectangleXy,1)
    options.frameId (1,1) double = 28
    options.sameLim (1, 1) logical = true
end
% register method call
obj.RegCall(mfilename);
% run dependent methods
obj.Flow_CallMethod({'ActMap_GetFileList',1});
obj.Flow_CallMethod({'ActMap_GetBregmaXy'; 'ActRoi_SetMask'; 'ActRoi_ApplyMask'; 'ActRoi_SetSessionPair'});

% remove mvtDir1 0 which is all mvtDir1 data
actRaw = obj.ActRoi.rawDiff;
actRaw(actRaw.mvtDir1==0,:) = [];

% check wether 8 mvtDir1 are present
mvtDir1 = unique(actRaw.mvtDir1);
if  ~ all(ismember(1:8,mvtDir1))
    % if not, return
    error('Not 8 mvtDir1');
end

% calculate axis limits
climits_min = min(cellfun(@(x) min(x(:)), actRaw.diffAvgF));
climits_max = max(cellfun(@(x) max(x(:)), actRaw.diffAvgF));
AxesLimits = [climits_min, climits_max];

% for each mouse, session

groupIDs = findgroups(actRaw(:,{'mouse1','pairType'}));
groupID = unique(groupIDs);


for i = progress(1:length(groupID),'Title','Plot avgFmean tuning')
    
    
    % get the actRoi for this mouse, session
    actRawMousePairType = actRaw(groupIDs==groupID(i),:);
    
    % remove mvtDir1 0
    actRawMousePairType(actRawMousePairType.mvtDir1==0,:) = [];
    
    % filter out sessions with less than 8 mvtDir1

    actRawMousePairType.sessionPair = cellfun(@(X,Y)[X,'-',Y], actRawMousePairType.session2, actRawMousePairType.session1, 'UniformOutput', false);
    actRawMousePairType = groupfilter(actRawMousePairType, 'sessionPair', @(x) ismember(x,1:8),'mvtDir1');
    
    
    actRawMousePairTypeDirF = [];
    for j = 1:8      
        actRawMousePairTypeDir = actRawMousePairType(actRawMousePairType.mvtDir1==j,:);
        actRawMousePairTypeDirFTem = cat(3, actRawMousePairTypeDir.diffAvgF{:});
        actRawMousePairTypeDirF = cat(4, actRawMousePairTypeDirF, actRawMousePairTypeDirFTem);
    end
    actRawMousePairTypeDirF = squeeze(actRawMousePairTypeDirF(options.frameId, :,:,:));
    actRawMousePairTypeDirF = actRawMousePairTypeDirF(options.roiId,:,:);
    
    cMouse = actRawMousePairType.mouse1{1};
    cGroup = actRawMousePairType.group1{1};
    cPairType = actRawMousePairType.pairType{1};
    cSessionPair = unique(actRawMousePairType.sessionPair);

    % plot the tuning curve for each roi
    for k = 1:size(actRawMousePairTypeDirF,1)
        % creat a new figure
        figure('Color','white','Position',[245,127,1525,800])
        % tiled layout
        tiledlayout(1,2,'TileSpacing','Compact','Padding','Compact');
        % plot the tuning spider plot
        nexttile;
        Param = struct();

        switch cGroup
            case 'Control'

                switch cPairType
                    case 'withinBaseline'
                        Param.title = sprintf('UntrainedGroup, %s : WithinBaseline', cMouse);
                    case 'trainingBaseline'
                        Param.title = sprintf('UntrainedGroup, %s : ParallelControlPeriod-Baseline', cMouse);
                end

            case 'Training'

                switch cPairType
                    case 'withinBaseline'
                        Param.title = sprintf('TrainedGroup, %s : WithinBaseline', cMouse);
                    case 'trainingBaseline'
                        Param.title = sprintf('TrainedGroup, %s : PostTraining-Baseline', cMouse);
                end

        end

        if options.sameLim
            Param.AxesLimits = AxesLimits;
        end
        
        Param.plotType = 'multiple';
        Param.legend = cSessionPair;
        Param1 = namedargs2cell(Param);
        SpiderPlotAvgFraw(squeeze(actRawMousePairTypeDirF(k,:,:)), Param1{:});
        
        nexttile;
        Param.plotType = 'meanSem';
        Param.legend = {'Mean±Sem'};
        Param = namedargs2cell(Param);
        SpiderPlotAvgFraw(squeeze(actRawMousePairTypeDirF(k,:,:)), Param{:});
        % save the figure
        exportgraphics(gcf,fullfile(obj.P.dir.actRoi.raw, sprintf('ActRoi_PlotAvgFrawTuningMean_%s_%s.png', cMouse, cPairType)),'resolution',300);
        close(gcf)
    end    
end

end