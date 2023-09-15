classdef FileTableActReg < FileTableAct
    %%Proporties
    properties
        mapAvg
    end

    %% Methods
    methods
        %% Constructor
        function obj = FileTableActReg(varargin)
            % Call superclass constructor
            obj = obj@FileTableAct(varargin{:});
            % Filter rows to only include raw data
            obj.Filter('actType', 'Reg');
        end

        %% Plot activation map
        function obj = PlotMap(obj)
            % If the deltaFoverF is not loaded, load it
            if ~ismember('deltaFoverF', obj.fileTable.Properties.VariableNames)
                obj.LoadDeltaFoverF();
            end

            % Calculate diffMapAvg
            G = findgroups(obj.fileTable(:, {'mouse'}));

            % Plot diffMapAvg for each mouse and pairType
            clim = cell2mat(cellfun(@(X)[min(X(:)), max(X(:))], obj.fileTable.deltaFoverF, 'UniformOutput', false));

            for i = 1:length(unique(G))
                thisMouseTable = obj.fileTable(G == i, :);
                % Determine the number of rows and columns of the plot, best be a square
                nPlot = height(thisMouseTable); nRow = ceil(sqrt(nPlot)); nCol = ceil(nPlot / nRow);
                % Create a figure
                figure('Name', 'mapAvg', 'Position', [100, 100, 1000, 1000], 'Color', 'w');

                for j = 1:height(thisMouseTable)
                    params = struct();
                    params.clim = max(abs(clim(:))) * [-1, 1];
                    params.title = [thisMouseTable.mouse{j}, ' (', thisMouseTable.session{j}, ')'];
                    params = namedargs2cell(params);
                    plotFrame(thisMouseTable.deltaFoverF{j}, subplot(nRow, nCol, j), params{:});
                end

            end

        end

        % Plot average activation map
        function obj = PlotAvgMap(obj)
            % If the deltaFoverF is not loaded, load it
            if ~ismember('deltaFoverF', obj.fileTable.Properties.VariableNames)
                obj.LoadDeltaFoverF();
            end

            % Calculate diffMapAvg
            [G, mosueGroupPhase] = findgroups(obj.fileTable(:, {'mouse', 'group', 'phase'}));
            meanMap = splitapply(@(X){mean(cat(3, X{1}), 3, 'omitnan')}, obj.fileTable.deltaFoverF, G);
            obj.mapAvg = [mosueGroupPhase, table(meanMap)];

            % Plot diffMapAvg for each mouse and pairType
            clim = cell2mat(cellfun(@(X)[min(X(:)), max(X(:))], obj.mapAvg.meanMap, 'UniformOutput', false));
            % Determine the number of rows and columns of the plot, best be a square
            nPlot = height(obj.mapAvg); nRow = ceil(sqrt(nPlot)); nCol = ceil(nPlot / nRow);
            % Create a figure
            figure('Name', 'mapAvg', 'Position', [100, 100, 1000, 1000], 'Color', 'w');

            for i = 1:height(obj.mapAvg)
                params = struct();
                params.clim = max(abs(clim(:))) * [-1, 1];
                params.title = [obj.mapAvg.mouse{i}, ' (', obj.mapAvg.phase{i}, ')'];
                params = namedargs2cell(params);
                plotFrame(obj.mapAvg.meanMap{i}, subplot(nRow, nCol, i), params{:});
            end

        end

    end

end
