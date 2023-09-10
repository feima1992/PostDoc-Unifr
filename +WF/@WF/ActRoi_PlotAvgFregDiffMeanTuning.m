function ActRoi_PlotAvgFregDiffMeanTuning(obj, options)
% validate inputs
arguments
    obj
    options.roiId (1, :) double = 1
    options.frameId (1, 1) double = 28
    options.sameLim (1, 1) logical = true
end

% register method call
obj.RegCall(mfilename);
% run dependent methods
obj.Flow_CallMethod({'ActMap_GetFileList', 1});
obj.Flow_CallMethod({'ActMap_GetBregmaXy'; 'ActRoi_SetMaskreg'; 'ActRoi_ApplyMaskreg'; 'ActRoi_SetSessionPair'});

% remove mvtDir 0, which is all movement direction data
actRegDiff = obj.ActRoi.regDiff;
actRegDiff(actRegDiff.mvtDir1 == 0, :) = [];

% check wether 8 mvtDir are present
mvtDir = unique(actRegDiff.mvtDir1);

if ~all(ismember(1:8, mvtDir))
    % if not, return
    error('Not 8 mvtDir data');
end

% calculate axis limits
climits_min = min(cellfun(@(x) min(x(:)), actRegDiff.diffAvgF));
climits_max = max(cellfun(@(x) max(x(:)), actRegDiff.diffAvgF));
AxesLimits = [climits_min, climits_max];

actRegDiff.moduleID = string(actRegDiff.module1);

%% load module info from google sheet
moduleInfoTable = ReadGoogleSheet(obj.P.gSheet.brainAtlasLabel);
moduleInfoTable = moduleInfoTable(:, {'num', 'hemisphere', 'moduleNameAbb', 'functionGroup'});
moduleInfoTable.moduleID = cellstr(string(moduleInfoTable.num));
% for each mouse, session

groupIDs = findgroups(actRegDiff(:, {'mouse1', 'pairType'}));
groupID = unique(groupIDs);

for i = progress(1:length(groupID), 'Title', 'Plot avgFmean tuning')
    
    % get the actRoi for this mouse, session
    actRegMousePhase = actRegDiff(groupIDs == groupID(i), :);
    [~, idx] = ismember(actRegMousePhase.moduleID, moduleInfoTable.moduleID);
    [~, idx] = sort(idx);
    actRegMousePhase = actRegMousePhase(idx, :);
    uniqueModule = unique(actRegMousePhase.moduleID,'stable');
    actRegMousePhase = actRegMousePhase(ismember(actRegMousePhase.moduleID, uniqueModule(options.roiId)), :);
    
    % remove mvtDir 0
    actRegMousePhase(actRegMousePhase.mvtDir1 == 0, :) = [];
    
    % filter out sessions with less than 8 mvtDir
    actRegMousePhase.sessionPair = cellfun(@(X,Y)[X,'-',Y], actRegMousePhase.session2, actRegMousePhase.session1, 'UniformOutput', false);
    actRegMousePhase = groupfilter(actRegMousePhase, 'session1', @(x) ismember(x, 1:8), 'mvtDir1');
    
    actRegMousePhaseDirF = [];
    
    for j = 1:8
        actRegMousePhaseDir = actRegMousePhase(actRegMousePhase.mvtDir1 == j, :);
        actRegMousePhaseDirFTem = cat(3, actRegMousePhaseDir.diffAvgF{:});
        actRegMousePhaseDirF = cat(4, actRegMousePhaseDirF, actRegMousePhaseDirFTem);
    end
    
    actRegMousePhaseDirF = squeeze(actRegMousePhaseDirF(options.frameId, :, :, :));
    
    cMouse = actRegMousePhase.mouse1{1};
    cGroup = actRegMousePhase.group1{1};
    cPairType = actRegMousePhase.pairType{1};
    cSession = unique(actRegMousePhase.sessionPair);
    
    % plot the tuning curve for each roi
    % creat a new figure
    figure('Color', 'white', 'Position', [245, 127, 1525, 800])
    % tiled layout
    tiledlayout(1, 2, 'TileSpacing', 'Compact', 'Padding', 'Compact');
    % plot the tuning spider plot
    nexttile;
    Param = struct();
    
    switch cGroup
        case 'Control'
            
            switch cPairType
                case 'withinBaseline'
                    titleStr = sprintf('UntrainedGroup, %s : WithinBaseline', cMouse);
                case 'trainingBaseline'
                    titleStr = sprintf('UntrainedGroup, %s : ParallelControlPeriod-Baseline', cMouse);
            end
            
        case 'Training'
            
            switch cPairType
                case 'withinBaseline'
                    titleStr = sprintf('TrainedGroup, %s : WithinBaseline', cMouse);
                case 'trainingBaseline'
                    titleStr = sprintf('TrainedGroup, %s : PostTraining-Baseline', cMouse);
            end
            
    end
    
    if options.sameLim
        Param.AxesLimits = AxesLimits;
    end
    
    Param.plotType = 'multiple';
    Param.legend = cSession;
    Param.title = titleStr;
    Param1 = namedargs2cell(Param);
    SpiderPlotAvgFraw(actRegMousePhaseDirF, Param1{:});
    
    nexttile;
    Param.plotType = 'meanSem';
    Param.legend = {'Mean±Sem'};
    Param = namedargs2cell(Param);
    SpiderPlotAvgFraw(actRegMousePhaseDirF, Param{:});
    % save the figure
    exportgraphics(gcf, fullfile(obj.P.dir.actRoi.reg, sprintf('ActRoi_PlotAvgFregTuningMean_%s_%s.png', cMouse, cPairType)), 'resolution', 300);
    close(gcf)
    
end

end
