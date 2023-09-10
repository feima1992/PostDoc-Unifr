function ActRoi_PlotAvgFregMeanTuning(obj, options)
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
    actReg = obj.ActRoi.reg;
    actReg(actReg.mvtDir == 0, :) = [];

    % check wether 8 mvtDir are present
    mvtDir = unique(actReg.mvtDir);

    if ~all(ismember(1:8, mvtDir))
        % if not, return
        error('Not 8 mvtDir data');
    end

    % calculate axis limits
    climits_min = min(cellfun(@(x) min(x(:)), actReg.avgF));
    climits_max = max(cellfun(@(x) max(x(:)), actReg.avgF));
    AxesLimits = [climits_min, climits_max];

    actReg.moduleID = cellfun(@(X)strjoin(string(X),''),actReg.module);

    %% load module info from google sheet
    moduleInfoTable = ReadGoogleSheet(obj.P.gSheet.brainAtlasLabel);
    moduleInfoTable = moduleInfoTable(:, {'num', 'hemisphere', 'moduleNameAbb', 'functionGroup'});
    moduleInfoTable.moduleID = cellstr(string(moduleInfoTable.num));     
    % for each mouse, session
    
    groupIDs = findgroups(actReg(:, {'mouse', 'phase'}));
    groupID = unique(groupIDs);

    for i = progress(1:length(groupID), 'Title', 'Plot avgFmean tuning')

        % get the actRoi for this mouse, session
        actRegMousePhase = actReg(groupIDs == groupID(i), :);
        [~, idx] = ismember(actRegMousePhase.moduleID, moduleInfoTable.moduleID);
        [~, idx] = sort(idx);
        actRegMousePhase = actRegMousePhase(idx, :);
        uniqueModule = unique(actRegMousePhase.moduleID,'stable');
        actRegMousePhase = actRegMousePhase(ismember(actRegMousePhase.moduleID, uniqueModule(options.roiId)), :);

        % remove mvtDir 0
        actRegMousePhase(actRegMousePhase.mvtDir == 0, :) = [];

        % filter out sessions with less than 8 mvtDir
        actRegMousePhase = groupfilter(actRegMousePhase, 'session', @(x) ismember(x, 1:8), 'mvtDir');

        actRegMousePhaseDirF = [];

        for j = 1:8
            actRegMousePhaseDir = actRegMousePhase(actRegMousePhase.mvtDir == j, :);
            actRegMousePhaseDirFTem = cat(3, actRegMousePhaseDir.avgF{:});
            actRegMousePhaseDirF = cat(4, actRegMousePhaseDirF, actRegMousePhaseDirFTem);
        end

        actRegMousePhaseDirF = squeeze(actRegMousePhaseDirF(options.frameId, :, :, :));

        cMouse = actRegMousePhase.mouse{1};
        cGroup = actRegMousePhase.group{1};
        cPhase = actRegMousePhase.phase{1};
        cSession = unique(actRegMousePhase.session);

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
            SpiderPlotAvgFraw(actRegMousePhaseDirF, Param1{:});

            nexttile;
            Param.plotType = 'meanSem';
            Param.legend = {'Mean±Sem'};
            Param = namedargs2cell(Param);
            SpiderPlotAvgFraw(actRegMousePhaseDirF, Param{:});
            % save the figure
            exportgraphics(gcf, fullfile(obj.P.dir.actRoi.reg, sprintf('ActRoi_PlotAvgFregTuningMean_%s_%s.png', cMouse, cPhase)), 'resolution', 300);
            close(gcf)

    end

end
