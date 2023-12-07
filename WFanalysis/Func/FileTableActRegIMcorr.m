classdef FileTableActRegIMcorr < FileTableActReg
    %% Methods
    methods
        %% Construcctor
        function obj = FileTableActRegIMcorr(varargin)
            % Call superclass constructor
            obj = obj@FileTableActReg(varargin{:});
        end

        %% Function load IMcorr
        function obj = LoadIMcorr(obj)
            % Notify the user that files are being loaded
            fprintf('   Loading IMcorr from %d files\n', height(obj.fileTable))
            tic;
            % Load deltaFoverF
            obj.fileTable = loadIMcorr(obj.fileTable, 'loadIMcorrType', 'IMcorrREG');
            % Notify the user that loading is done and how long it took
            fprintf('   Loading IMcorr from %d files took %.2f seconds\n', height(obj.fileTable), toc)
        end

        %% Plot activation map for each mouse and session (NormIMcorr)
        function obj = PlotMap(obj)

            % If the IMcorr is not loaded, load it
            if ~ismember('IMcorr', obj.fileTable.Properties.VariableNames)
                obj.LoadIMcorr();
            end

            % Plot NormIMcorr for each mouse
            G = findgroups(obj.fileTable(:, {'mouse'}));

            for i = 1:length(unique(G))
                thisMouseTable = obj.fileTable(G == i, :);
                % Plot each frame of the NormIMcorr
                for j = 21:31
                    % Create frameData to be plotted and frameTime
                    frameData = cellfun(@(X)X(:, :, j), thisMouseTable.IMcorr, 'UniformOutput', false);
                    frameTime = sprintf('%.2f', Param().wfAlign.frameTime(j));
                    % Create a figure
                    figure('Name', 'mapAvg', 'Position', [100, 100, 1000, 1000], 'Color', 'w');
                    % Create titleStr and sgtitleStr
                    sgtitleStr = [thisMouseTable.mouse{1}, ' (', thisMouseTable.group{1}, ')' ' @ ', frameTime, 's'];
                    titleStr = cellfun(@(X, Y)[X, ' (', Y, ')'], thisMouseTable.phase, thisMouseTable.session, 'UniformOutput', false);
                    % Plot thisMouseTable.deltaFoverF
                    imshowMultiFrames(frameData, 'title', titleStr, 'sgtitle', sgtitleStr, 'cmap', fire(256));

                    % format the figure

                    nPost = sum(~strcmp(thisMouseTable.phase, 'Baseline'));
                    axesH = findobj(gcf, 'Type', 'ax');

                    for k = 1:nPost
                        axesH(k).Title.Color = 'r';
                    end

                    for l = nPost + 1:length(axesH)
                        axesH(l).Title.Color = 'b';
                    end

                    switch length(axesH)
                        case {11, 12}
                            set(gcf, 'Position', [0, 400, 2000, 600]);
                        case {13, 14, 15, 16, 17, 18}
                            set(gcf, 'Position', [0, 400, 2000, 900]);
                    end

                    if strcmp(thisMouseTable.group{1}, 'Untrained')
                        prefix = 'con';
                    else
                        prefix = 'exp';
                    end

                    % save the figure
                    figName = [prefix, '_', thisMouseTable.mouse{1}, '_normIMcorr_frame', num2str(j), '.png'];
                    figPath = fullfile(Param().folderFigure, thisMouseTable.mouse{1}, figName);
                    % create folder if not exist
                    if ~isfolder(fileparts(figPath))
                        mkdir(fileparts(figPath));
                    end

                    exportgraphics(gcf, figPath, 'Resolution', 300);
                    close(gcf);
                end

            end

        end

        %% Plot average activation map for each mouse (NormIMcorr)
        function obj = PlotAvgMap(obj)
            % If the IMcorr is not loaded, load it
            if ~ismember('IMcorr', obj.fileTable.Properties.VariableNames)
                obj.LoadIMcorr();
            end

            % Calculate average IMcorr for each mouse and phase
            [G, mosueGroupPhase] = findgroups(obj.fileTable(:, {'mouse', 'group', 'phase'}));
            meanMap = splitapply(@(X){mean(cat(4, X{1}), 4, 'omitnan')}, obj.fileTable.IMcorr, G);
            meanMap = [mosueGroupPhase, table(meanMap)];

            % Calculate difference map for each mouse
            baselineIdx = strcmp(meanMap.phase, 'Baseline');
            meanMapPaired = innerjoin(meanMap(baselineIdx, :), meanMap(~baselineIdx, :), 'Keys', 'mouse');
            % fill nan with 0 to prevent wrong subtraction
            meanMapPaired.meanMap_left = cellfun(@(X)fillmissing(X, 'constant', 0), meanMapPaired.meanMap_left, 'UniformOutput', false);
            meanMapPaired.meanMap_right = cellfun(@(X)fillmissing(X, 'constant', 0), meanMapPaired.meanMap_right, 'UniformOutput', false);
            meanMapPaired.diffMap = cellfun(@(X, Y)X - Y, meanMapPaired.meanMap_right, meanMapPaired.meanMap_left, 'UniformOutput', false);

            % Plot meanMapPaired for each mouse
            for i = 1:height(meanMapPaired)

                for j = 21:31
                    % Create a figure
                    figure('Name', 'mapAvg', 'Position', [100, 100, 1000, 1000], 'Color', 'w');
                    % Create frameData to be plotted
                    frameData = {meanMapPaired.meanMap_left{i}(:, :, j), meanMapPaired.meanMap_right{i}(:, :, j)};
                    titleStr = {meanMapPaired.phase_left{i}, meanMapPaired.phase_right{i}};
                    sgtitleStr = [meanMapPaired.mouse{i}, ' (', meanMapPaired.group_left{i}, ')' ' @ ', sprintf('%.2f', Param().wfAlign.frameTime(j)), 's'];
                    imshowMultiFrames(frameData, 'title', titleStr, 'sgtitle', sgtitleStr, 'cmap', fire(256), 'flow', true);
                    nexttile;
                    imagescFrame(meanMapPaired.diffMap{i}(:, :, j), 'colorbarLabel', 'Diff');
                    set(gcf, 'Position', [0, 400, 1000, 300]);
                    axesH = findobj(gcf, 'Type', 'ax');
                    axesH(3).Title.Color = 'b'; axesH(2).Title.Color = 'r';

                    if strcmp(meanMapPaired.group_left{i}, 'Untrained')
                        prefix = 'con';
                    else
                        prefix = 'exp';
                    end

                    % save the figure
                    figName = [prefix, '_', meanMapPaired.mouse{i}, '_normIMcorrAvg_frame', num2str(j), '.png'];
                    figPath = fullfile(Param().folderFigure, meanMapPaired.mouse{i}, figName);
                    % create folder if not exist
                    if ~isfolder(fileparts(figPath))
                        mkdir(fileparts(figPath));
                    end

                    exportgraphics(gcf, figPath, 'Resolution', 300);
                    close(gcf);
                end

            end

        end

        %% Plot IMcorr properties
        function obj = CalActProps(obj)

            if ~ismember('IMcorr', obj.fileTable.Properties.VariableNames)
                obj.LoadIMcorr();
            end

            for i = 1:height(obj.fileTable)
                obj.fileTable.IMcorr{i} = FramesIMcorr(obj.fileTable.IMcorr{i},Param().wfAlign.frameTime).CalRegionProps().frameProps;
            end

            obj.fileTable = expendColumn(obj.fileTable, 'IMcorr');
        end

    end

end
