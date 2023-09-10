function ActRoi_PlotAvgFregMean(obj, options)

    arguments
        obj
        options.sameLim (1, 1) logical = true
    end

    obj.ActRoi.reg.moduleID = string(obj.ActRoi.reg.module);
    groupIDs = findgroups(obj.ActRoi.reg(:, {'mouse', 'phase', 'moduleID'}));
    groupID = unique(groupIDs);

    avgFregGrouped = table();

    for i = 1:length(groupID)
        thisAvgFreg = obj.ActRoi.reg(groupIDs == groupID(i), :);
        thisAvgFreg = sortrows(thisAvgFreg, 'session');
        avgFregGrouped.mouse{i} = thisAvgFreg.mouse{1};
        avgFregGrouped.group{i} = thisAvgFreg.group{1};
        avgFregGrouped.phase{i} = thisAvgFreg.phase{1};
        avgFregGrouped.moduleID{i} = thisAvgFreg.moduleID{1};
        avgFregGrouped.session{i} = thisAvgFreg.session;
        avgFregGrouped.avgF{i} = cat(2, thisAvgFreg.avgF{:});
        avgFregGrouped.avgFmean{i} = mean(cat(2, thisAvgFreg.avgF{:}), 2);
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
    groupIDs = findgroups(avgFregGrouped(:, {'mouse', 'phase'}));
    groupID = unique(groupIDs);

    for i = progress(1:height(groupID), 'Title', '  Plot regMean')
        thisAvgFreg = avgFregGrouped(groupIDs == groupID(i), :);
        % sort thisAvgFreg by num which should have the same order as moduleInfoTable.num
        [~, idx] = ismember(thisAvgFreg.moduleID, moduleInfoTable.moduleID);
        [~, idx] = sort(idx);
        thisAvgFreg = thisAvgFreg(idx, :);
        % extract info
        cMouse = thisAvgFreg.mouse{i};
        cGroup = thisAvgFreg.group{i};
        cPhase = thisAvgFreg.phase{i};
        cSession = thisAvgFreg.session{i};
        cAvgFMean = cat(2, thisAvgFreg.avgFmean{:});
        cAvgF = cat(3, thisAvgFreg.avgF{:});
        cAvgFmax = squeeze(cAvgF(28, :, :));
        cRoiLabel = cellfun(@(x, y) sprintf('%s-%s', x, y), thisAvgFreg.hemisphere, thisAvgFreg.moduleNameAbb, 'UniformOutput', false);

        % initialize figure
        figH = figure('Color', 'w', 'Position', [13,221,1920,660]);

        switch cGroup
            case 'Control'
                
                switch cPhase
                    case 'Baseline'
                        titleStr = sprintf('UntrainedGroup, %s: Baseline', cMouse);
                    case 'Training'
                        titleStr = sprintf('UntrainedGroup, %s: ParallelControlPeriod', cMouse);
                end
                
            case 'Training'
                
                switch cPhase
                    case 'Baseline'
                        titleStr = sprintf('TrainedGroup, %s: Baseline', cMouse);
                    case 'Training'
                        titleStr = sprintf('TrainedGroup, %s: ParallelControlPeriod', cMouse);
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
        exportgraphics(figH, fullfile(obj.P.dir.actRoi.reg, sprintf('%s_%s_ActRoiReg.png', cMouse, cPhase)), 'Resolution', 300);
        close(figH)
    end

end
