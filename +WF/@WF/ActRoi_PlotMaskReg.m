function ActRoi_PlotMaskReg(obj, ax, options)

    % Validate input arguments
    arguments
        obj
        ax (1, 1) matlab.graphics.axis.Axes = axes('Parent', gcf);
        options.label (1, 1) logical = true
    end

    obj.RegCall(mfilename);
    obj.Flow_CallMethod({'ActRoi_SetMaskReg'});

    %% Plot the ROI

    % if ax is provided, plot on it
    if ~isempty(ax)
        axes(ax);
    end

    if ~isfield(obj.ActRoi.mask.reg, 'moduleLabel')
        % read the ABM template image
        abmTemplate = imread(obj.P.path.abmTemplate);

        % get outline of cortex modules from the ABM template image
        moduleOutline = double(bwskel(abmTemplate == 0));

        % label the modules in the ABM template image
        obj.ActRoi.mask.reg.moduleLabel = bwlabel(~moduleOutline, 4);
    end

    % plot the module mask
    moduleLabel = obj.ActRoi.mask.reg.moduleLabel;
    selectLabel = {obj.ActRoi.mask.reg.selectLabel};

    % initialize the module label for plotting
    moduleLabelPlot = zeros(size(moduleLabel));
    moduleLabelPlot(moduleLabel == 0) = 0; % outline
    moduleLabelPlot(moduleLabel == 1) = 1; % background
    moduleLabelPlot(moduleLabel > 1) = 2; % modules

    for i = 1:length(selectLabel)
        moduleLabelPlot(ismember(moduleLabel, selectLabel{i})) = i + 2;
    end

    imagesc(moduleLabelPlot); axis image; axis off; colormap(colorcube(length(selectLabel) + 3));
    % remap the color map
    cColor = colormap;
    cColor(1, :) = [0, 0, 0]; % black edge color
    cColor(2, :) = [1, 1, 1]; % white background
    cColor(3, :) = [0.9, 0.9, 0.9]; % gray unselected modules
    cColor(4:end, :) = lines(length(selectLabel)); % color selected modules
    colormap(cColor);
    % add colorbar

%{
     cb = colorbar;
    intervalTicks = (cb.Ticks(end)-cb.Ticks(1))/length(cb.Ticks);
    cb.Ticks = linspace(cb.Ticks(1)+intervalTicks/2, cb.Ticks(end)-intervalTicks/2, length(cb.Ticks));
    cb.TickLabels = [0,0,0,selectLabel];
    cb.Limits = [cb.Ticks(4)-intervalTicks/2, cb.Ticks(end)+intervalTicks/2];
%}

    % add number label
    if options.label
        moudleLabelAsc = sort(unique(moduleLabel));

        moduleName = ReadGoogleSheet(obj.P.gSheet.brainAtlasLabel);

        for j = 3:length(moudleLabelAsc)
            % find center of moduleLabels == labels(i)
            [y, x] = find(moduleLabel == moudleLabelAsc(j));
            % find the corresponding module name
            thisModuleName = moduleName.moduleNameAbb(moduleName.num == moudleLabelAsc(j));

            % show the label for region larger than 50 pixels
            if length(x) > 50 && (~isempty(thisModuleName))
                text(mean(x), mean(y), thisModuleName{1}, 'Color', 'k', 'FontSize', 8, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontWeight', 'bold');
            end

        end

    end

    % set the title
    set(get(gca, 'Title'), 'String', 'ROI: Module Mask');
end
