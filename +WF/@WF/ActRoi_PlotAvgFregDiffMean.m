function ActRoi_PlotAvgFregDiffMean(obj, options)

    arguments
        obj
        options.sameLim (1, 1) logical = true
    end

    obj.ActRoi.regDiff.moduleID = string(obj.ActRoi.regDiff.module1);
    groupIDs = findgroups(obj.ActRoi.regDiff(:, {'mouse1', 'pairType', 'moduleID'}));
    groupID = unique(groupIDs);

    avgFregGrouped = table();

    for i = 1:length(groupID)
        thisAvgFreg = obj.ActRoi.regDiff(groupIDs == groupID(i), :);
        thisAvgFreg = sortrows(thisAvgFreg, 'session2');
        avgFregGrouped.mouse{i} = thisAvgFreg.mouse1{1};
        avgFregGrouped.group{i} = thisAvgFreg.group1{1};
        avgFregGrouped.pairType{i} = thisAvgFreg.pairType{1};
        avgFregGrouped.moduleID{i} = thisAvgFreg.moduleID{1};
        avgFregGrouped.session{i} = cellfun(@(X,Y) sprintf('%s-%s', X, Y), thisAvgFreg.session2, thisAvgFreg.session1, 'UniformOutput', false);
        avgFregGrouped.avgF{i} = cat(2, thisAvgFreg.diffAvgF{:});
        avgFregGrouped.avgFmean{i} = mean(cat(2, thisAvgFreg.diffAvgF{:}), 2);
    end

    %% load module info from google sheet
    moduleInfoTable = ReadGoogleSheet(obj.P.gSheet.brainAtlasLabel);
    moduleInfoTable = moduleInfoTable(:, {'num', 'hemisphere', 'moduleNameAbb', 'functionGroup'});
    moduleInfoTable.moduleID = cellstr(string(moduleInfoTable.num));
    avgFregGrouped = outerjoin(avgFregGrouped, moduleInfoTable, 'Type', 'left', 'Keys', 'moduleID', 'MergeKeys', true);

    %% plot
    if options.sameLim
        climits_min = min(cellfun(@(x) min(x(:)), avgFregGrouped.avgF));
        climits_max = max(cellfun(@(x) max(x(:)), avgFregGrouped.avgF));
        ylimits = [climits_min, climits_max];
        % keep the colorbar limits symmetric
        climits = max(abs(climits_min), abs(climits_max)) * [-1, 1];
    end

    % for each mouse and phase, plot the average ΔF/F of all modules
    groupIDs = findgroups(avgFregGrouped(:, {'mouse', 'pairType'}));
    groupID = unique(groupIDs);

    for i = progress(1:height(groupID), 'Title', '  Plot regDiffMean')
        thisAvgFreg = avgFregGrouped(groupIDs == groupID(i), :);
        % sort thisAvgFreg by num which should have the same order as moduleInfoTable.num
        [~, idx] = ismember(thisAvgFreg.moduleID, moduleInfoTable.moduleID);
        [~, idx] = sort(idx);
        thisAvgFreg = thisAvgFreg(idx, :);
        % extract info
        cMouse = thisAvgFreg.mouse{i};
        cGroup = thisAvgFreg.group{i};
        cPairType = thisAvgFreg.pairType{i};
        cSession = thisAvgFreg.session{i};
        cAvgFMean = cat(2, thisAvgFreg.avgFmean{:});
        cAvgF = cat(3, thisAvgFreg.avgF{:});
        cAvgFmax = squeeze(cAvgF(28, :, :));
        cRoiLabel = cellfun(@(x, y) sprintf('%s-%s', x, y), thisAvgFreg.hemisphere, thisAvgFreg.moduleNameAbb, 'UniformOutput', false);

        % initialize figure
        figH = figure('Color', 'w', 'Position', [13,221,1920,660]);

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

        % line plot of avgFmax
        Param = struct();
        Param.ax = subplot(1, 2, 1);
        Param.X = 1:length(cRoiLabel);
        Param.XLabel = cRoiLabel;

        if options.sameLim
            Param.ylim = ylimits;
        end

        Param.legend = cSession;
        Param.title = 'T = 0.35s';
        Param1 = namedargs2cell(Param);
        LinePlotAvgFreg(cAvgFmax', Param1{:})

        % plot ROI average ΔF/F
        Param = struct();
        Param.ax = subplot(1, 2, 2);
        Param.X = cRoiLabel;
        Param.Y = obj.P.wf.frame.time;

        if options.sameLim
            Param.climits = climits;
        end

        Param.title = titleStr;
        Param = namedargs2cell(Param);
        HeatMapAvgFreg(cAvgFMean, Param{:});
        exportgraphics(figH, fullfile(obj.P.dir.actRoi.reg, sprintf('%s_%s_ActRoiReg.png', cMouse, cPairType)), 'Resolution', 300);
        close(figH)
    end

end
