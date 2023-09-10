function ActRoi_PlotAvgFrawMean(obj, options)
    % validate inputs
    arguments
        obj
        options.sameLim (1, 1) logical = true
    end

    % register method call
    obj.RegCall(mfilename);
    % run dependent methods
    obj.Flow_CallMethod({'ActMap_GetFileList'; 'ActMap_GetBregmaXy'; 'ActRoi_SetMask'; 'ActRoi_ApplyMaskRaw'});

    % plot a figure for each mouse (average across sessions)
    groupIDs = findgroups(obj.ActRoi.raw(:, {'mouse', 'phase'}));
    groupID = unique(groupIDs);

    avgF = struct();
    % for each groupID plot a figure
    for i = 1:length(groupID)
        thisGroup = obj.ActRoi.raw(groupIDs == i, :);
        % extract info
        cMouse = thisGroup.mouse{1};
        cGroup = thisGroup.group{1};
        cPhase = thisGroup.phase{1};
        cSession = thisGroup.session;
        cAvgF = thisGroup.avgF;
        cAvgF = cat(3, cAvgF{:});
        cAvgFmean = nanmean(cAvgF, 3);
        cAvgFsd = nanstd(cAvgF, [], 3);
        cAvgFse = cAvgFsd ./ sqrt(size(cAvgF, 3));

        % save to struct
        avgF(i).mouse = cMouse;
        avgF(i).group = cGroup;
        avgF(i).phase = cPhase;
        avgF(i).cSession = cSession;
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
        cPhase = avgFtable.phase{i};
        cSession = avgFtable.cSession{i};
        cAvgF = avgFtable.avgF{i};
        cAvgFmean = avgFtable.avgFmean{i};
        cAvgFMax = squeeze(cAvgF(28, :, :));

        % initialize figure
        figH = figure('Color', 'w', 'Position', [300, 450, 1500, 500]);

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

                switch cPhase
                    case 'Baseline'
                        Param.title = sprintf('NoTraining, %s : Pre', cMouse);
                    case 'Training'
                        Param.title = sprintf('NoTraining, %s : Post', cMouse);
                end

            case 'Training'

                switch cPhase
                    case 'Baseline'
                        Param.title = sprintf('Training, %s : Pre', cMouse);
                    case 'Training'
                        Param.title = sprintf('Training, %s : Post', cMouse);
                end

        end

        Param = namedargs2cell(Param);

        HeatMapAvgFraw(cAvgFmean, Param{:});

         exportgraphics(figH, fullfile(obj.P.dir.actRoi.raw, sprintf('%s_%s_ActRoiRaw.png', cMouse, cPhase)), 'Resolution', 300);
        close(figH)
    end

end
