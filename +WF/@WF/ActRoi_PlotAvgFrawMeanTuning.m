function ActRoi_PlotAvgFrawMeanTuning(obj, options)
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

% remove mvtDir 0 which is all mvtDir data
actRaw = obj.ActRoi.raw;
actRaw(actRaw.mvtDir==0,:) = [];

% check wether 8 mvtDir are present
mvtDir = unique(actRaw.mvtDir);
if  ~ all(ismember(1:8,mvtDir))
    % if not, return
    error('Not 8 mvtDir');
end

% calculate axis limits
climits_min = min(cellfun(@(x) min(x(:)), actRaw.avgF));
climits_max = max(cellfun(@(x) max(x(:)), actRaw.avgF));
AxesLimits = [climits_min, climits_max];

% for each mouse, session

groupIDs = findgroups(actRaw(:,{'mouse','phase'}));
groupID = unique(groupIDs);


for i = progress(1:length(groupID),'Title','Plot avgFmean tuning')
    
    
    % get the actRoi for this mouse, session
    actRawMousePhase = actRaw(groupIDs==groupID(i),:);
    
    % remove mvtDir 0
    actRawMousePhase(actRawMousePhase.mvtDir==0,:) = [];
    
    % filter out sessions with less than 8 mvtDir
    actRawMousePhase = groupfilter(actRawMousePhase, 'session', @(x) ismember(x,1:8),'mvtDir');
    
    
    actRawMousePhaseDirF = [];
    for j = 1:8      
        actRawMousePhaseDir = actRawMousePhase(actRawMousePhase.mvtDir==j,:);
        actRawMousePhaseDirFTem = cat(3, actRawMousePhaseDir.avgF{:});
        actRawMousePhaseDirF = cat(4, actRawMousePhaseDirF, actRawMousePhaseDirFTem);
    end
    actRawMousePhaseDirF = squeeze(actRawMousePhaseDirF(options.frameId, :,:,:));
    actRawMousePhaseDirF = actRawMousePhaseDirF(options.roiId,:,:);
    
    cMouse = actRawMousePhase.mouse{1};
    cGroup = actRawMousePhase.group{1};
    cPhase = actRawMousePhase.phase{1};
    cSession = unique(actRawMousePhase.session);

    % plot the tuning curve for each roi
    for k = 1:size(actRawMousePhaseDirF,1)
        % creat a new figure
        figure('Color','white','Position',[245,127,1525,800])
        % tiled layout
        tiledlayout(1,2,'TileSpacing','Compact','Padding','Compact');
        % plot the tuning spider plot
        nexttile;
        Param = struct();
        switch cGroup
            case 'Control'

                switch cPhase
                    case 'Baseline'
                        titleStr = sprintf('UntrainedGroup, %s : Baseline', cMouse);
                    case 'Training'
                        titleStr = sprintf('UntrainedGroup, %s : ParallelControlPeriod', cMouse);
                end

            case 'Training'

                switch cPhase
                    case 'Baseline'
                        titleStr = sprintf('TrainedGroup, %s : Baseline', cMouse);
                    case 'Training'
                        titleStr = sprintf('TrainedGroup, %s : PostTraining', cMouse);
                end

        end

        if options.sameLim
            Param.AxesLimits = AxesLimits;
        end
        
        Param.plotType = 'multiple';
        Param.legend = cSession;
        Param.title = titleStr;
        Param1 = namedargs2cell(Param);
        SpiderPlotAvgFraw(squeeze(actRawMousePhaseDirF(k,:,:)), Param1{:});
        
        nexttile;
        Param.plotType = 'meanSem';
        Param.legend = {'Mean±Sem'};
        Param = namedargs2cell(Param);
        SpiderPlotAvgFraw(squeeze(actRawMousePhaseDirF(k,:,:)), Param{:});
        % save the figure
        exportgraphics(gcf,fullfile(obj.P.dir.actRoi.raw, sprintf('ActRoi_PlotAvgFrawTuningMean_%s_%s.png', cMouse, cPhase)),'resolution',300);
        close(gcf)
    end    
end

end