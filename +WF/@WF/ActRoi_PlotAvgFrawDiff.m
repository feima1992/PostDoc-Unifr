function ActRoi_PlotAvgFrawDiff(obj, options)
    % validate inputs
    arguments
        obj
        options.sameLim (1, 1) logical = true
    end

    % register method call
    obj.RegCall(mfilename);
    % run dependent methods
    obj.Flow_CallMethod({'ActMap_GetFileList'; 'ActMap_GetBregmaXy'; 'ActRoi_SetMask'; 'ActRoi_ApplyMask'; 'ActRoi_SetSessionPair'})

    % plot a figure for each mouse/session

    % calculate colorbar limits
    climits_min = min(cellfun(@(x) min(x(:)), obj.ActRoi.rawDiff.diffAvgF));
    climits_max = max(cellfun(@(x) max(x(:)), obj.ActRoi.rawDiff.diffAvgF));
    % keep the colorbar limits symmetric
    ylimits = [climits_min, climits_max];
    climitsSym = max(abs(climits_min), abs(climits_max)) * [-1, 1];

    for i = progress(1:height(obj.ActRoi.rawDiff), 'Title', '  Plot avgF rawDiff')

        % extract info
        cMouse = obj.ActRoi.rawDiff.mouse1{i};
        cGroup = obj.ActRoi.rawDiff.group1{i};
        cPairType = obj.ActRoi.rawDiff.pairType{i};
        cSession1 = obj.ActRoi.rawDiff.session1{i};
        cSession2 = obj.ActRoi.rawDiff.session2{i};
        cAvgF = obj.ActRoi.rawDiff.diffAvgF{i};

        cAvgFMax = cAvgF(sub2ind(size(cAvgF), ones(1, size(cAvgF, 2)) * 28, 1:length(obj.ActRoi.rawDiff.maxAvgFid1{i})));

        % initialize figure
        figH = figure('Color', 'w', 'Position', [300, 450, 1500, 500]);

        % line plot of avgFmax
        Param = struct();
        Param.ax = subplot(1, 2, 1);
        Param.X = obj.ActRoi.mask.raw.centerXy(:, 1);

        if options.sameLim
            Param.ylimits = ylimits;
        end

        Param.title = 'T = 0.35s';
        Param = namedargs2cell(Param);
        LinePlotAvgFraw(cAvgFMax, Param{:})

        % heatmap of avgF rawDiff
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
                        Param.title = sprintf('NoTraining, %s: %s-%s (Pre-Pre)', cMouse, cSession2, cSession1);
                    case 'trainingBaseline'
                        Param.title = sprintf('NoTraining, %s: %s-%s (Post-Pre)', cMouse, cSession2, cSession1);
                end

            case 'Training'

                switch cPairType
                    case 'withinBaseline'
                        Param.title = sprintf('Training, %s: %s-%s (Pre-Pre)', cMouse, cSession2, cSession1);
                    case 'trainingBaseline'
                        Param.title = sprintf('Training, %s: %s-%s (Post-Pre)', cMouse, cSession2, cSession1);
                end

        end

        Param = namedargs2cell(Param);

        HeatMapAvgFraw(cAvgF, Param{:});

        exportgraphics(figH, fullfile(obj.P.dir.actRoi.rawDiff, sprintf('%s_%s-%s_ActRoiRaw.png', cMouse, cSession2, cSession1)), 'Resolution', 300);
        close(figH)
    end

end
