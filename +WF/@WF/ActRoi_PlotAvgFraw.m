function ActRoi_PlotAvgFraw(obj, options)
    % validate inputs
    arguments
        obj
        options.sameLim (1, 1) logical = true
        options.sameMaxAvgFid (1, 1) logical = true % if true, plot the same frame for each session (28th frame of 51 frames)
    end

    % register method call
    obj.RegCall(mfilename);
    % run dependent methods
    obj.Flow_CallMethod({'ActMap_GetFileList'; 'ActMap_GetBregmaXy'; 'ActRoi_SetMask'; 'ActRoi_ApplyMask'})

    % plot a figure for each mouse/session

    % calculate colorbar limits
    climits_min = min(cellfun(@(x) min(x(:)), obj.ActRoi.raw.avgF));
    climits_max = max(cellfun(@(x) max(x(:)), obj.ActRoi.raw.avgF));
    % keep the colorbar limits symmetric
    ylimits = [climits_min, climits_max];
    climitsSym = max(abs(climits_min), abs(climits_max)) * [-1, 1];

    for i = progress(1:height(obj.ActRoi.raw), 'Title', '  Plot avgF raw')

        % extract info
        cMouse = obj.ActRoi.raw.mouse{i};
        cGroup = obj.ActRoi.raw.group{i};
        cPhase = obj.ActRoi.raw.phase{i};
        cSession = obj.ActRoi.raw.session{i};
        cAvgF = obj.ActRoi.raw.avgF{i};

        if options.sameMaxAvgFid
            cAvgFMax = cAvgF(sub2ind(size(cAvgF), ones(1, size(cAvgF, 2)) * 28, 1:length(obj.ActRoi.raw.maxAvgFid{i})));
        else
            cAvgFMax = cAvgF(sub2ind(size(cAvgF), obj.ActRoi.raw.maxAvgFid{i}, 1:length(obj.ActRoi.raw.maxAvgFid{i})));
        end

        % initialize figure
        figH = figure('Color', 'w', 'Position', [300, 450, 1500, 500]);

        % line plot of avgFmax
        Param = struct();
        Param.ax = subplot(1, 2, 1);
        Param.X = obj.ActRoi.mask.raw.centerXy(:, 1);

        if options.sameLim
            Param.ylim = ylimits;
        end

        if options.sameMaxAvgFid
            Param.title = 'T = 0.35s';
        else
            Param.title = 'Max intensity frame';
        end

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
                        Param.title = sprintf('NoTraining, %s: %s(Pre)', cMouse, cSession);
                    case 'Training'
                        Param.title = sprintf('NoTraining, %s: %s(Post)', cMouse, cSession);
                end

            case 'Training'

                switch cPhase
                    case 'Baseline'
                        Param.title = sprintf('Training, %s: %s(Pre)', cMouse, cSession);
                    case 'Training'
                        Param.title = sprintf('Training, %s: %s(Post)', cMouse, cSession);
                end

        end

        Param = namedargs2cell(Param);

        HeatMapAvgFraw(cAvgF, Param{:});

        exportgraphics(figH, fullfile(obj.P.dir.actRoi.raw, sprintf('%s_%s_ActRoiRaw.png', cMouse, cSession)), 'Resolution', 300);
        close(figH)
    end

end
