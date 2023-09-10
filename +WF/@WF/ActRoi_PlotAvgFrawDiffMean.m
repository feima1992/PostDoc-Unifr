function ActRoi_PlotAvgFrawDiffMean(obj, options)
    % validate inputs
    arguments
        obj
        options.sameLim (1, 1) logical = true
    end

    % register method call
    obj.RegCall(mfilename);
    % run dependent methods
    obj.Flow_CallMethod({'ActMap_GetFileList'; 'ActMap_GetBregmaXy'; 'ActRoi_SetMask'; 'ActRoi_ApplyMask'; 'ActRoi_SetSessionPair'});

    % plot a figure for each mouse and pairType
    groupIDs = findgroups(obj.ActRoi.rawDiff(:, {'mouse1', 'pairType'}));
    groupID = unique(groupIDs);
    avgF = struct();

    % for each groupID plot a figure
    for i = 1:length(groupID)
        thisGroup = obj.ActRoi.rawDiff(groupIDs == i, :);
        % sort by session2
        thisGroup = sortrows(thisGroup, 'session2');
        % extract info
        cMouse = thisGroup.mouse1{1};
        cGroup = thisGroup.group1{1};
        cPairType = thisGroup.pairType{1};
        cSession1 = thisGroup.session1;
        cSession2 = thisGroup.session2;
        cAvgF = thisGroup.diffAvgF;
        cAvgF = cat(3, cAvgF{:});
        cAvgFmean = nanmean(cAvgF, 3);
        cAvgFsd = nanstd(cAvgF, [], 3);
        cAvgFse = cAvgFsd ./ sqrt(size(cAvgF, 3));

        % save to struct
        avgF(i).mouse = cMouse;
        avgF(i).group = cGroup;
        avgF(i).pairType = cPairType;
        avgF(i).cSession = cellfun(@(x, y) sprintf('%s-%s', x, y), cSession2, cSession1, 'UniformOutput', false);
        avgF(i).avgF = cAvgF;
        avgF(i).avgFmean = cAvgFmean;
        avgF(i).avgFsd = cAvgFsd;
        avgF(i).avgFse = cAvgFse;

    end

    avgFtable = struct2table(avgF);

    % calculate colorbar limits

    climits_min = min(cellfun(@(x) min(x(:)), avgFtable.avgF));
    climits_max = max(cellfun(@(x) max(x(:)), avgFtable.avgF));
    % keep the colorbar limits symmetric
    ylimits = [climits_min, climits_max];
    climitsSym = max(abs(climits_min), abs(climits_max)) * [-1, 1];

    % plot a figure
    for i = progress(1:height(avgFtable), 'Title', '  Plot avgF rawMean')
        % extract info
        cMouse = avgFtable.mouse{i};
        cGroup = avgFtable.group{i};
        cPairType = avgFtable.pairType{i};
        cSession = avgFtable.cSession{i};
        cAvgF = avgFtable.avgF{i};
        cAvgFmean = avgFtable.avgFmean{i};
        cAvgFMax = squeeze(cAvgF(28, :, :));

        % initialize figure
        figH = figure('Color', 'w', 'Position', [70, 340, 1800, 650]);

        % line plot of avgFmax
        Param = struct();
        Param.ax = subplot(1, 2, 1);
        Param.X = obj.ActRoi.mask.raw.centerXy(:, 1);

        if options.sameLim
            Param.ylim = ylimits;
        end

        Param.legend = cSession;
        Param.title = 'T = 0.35s';
        Param = namedargs2cell(Param);
        LinePlotAvgFraw(cAvgFMax, Param{:})

        % heatmap of avgF raw
        Param = struct();
        Param.ax = subplot(1, 2, 2);
        Param.X = obj.ActRoi.mask.raw.centerXy(:, 1);
        Param.Y = obj.P.wf.frame.time;

        if options.sameLim
            Param.climits = climitsSym;
        end

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

        Param = namedargs2cell(Param);

        HeatMapAvgFraw(cAvgFmean, Param{:});

        exportgraphics(figH, fullfile(obj.P.dir.actRoi.rawDiff, sprintf('%s_%s_ActRoiRaw.png', cMouse, cPairType)), 'Resolution', 300);
        close(figH)
    end

end
