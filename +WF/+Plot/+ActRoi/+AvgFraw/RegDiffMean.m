function RegDiffMean(avgFreg,P, options)
    arguments
        avgFreg table
        P (1,1) struct
        options.sameClim (1,1) logical = true
    end
    %% orgnize data
    avgFreg.diffAvgF = cellfun(@(x) x', avgFreg.diffAvgF, 'UniformOutput', false);
    groupT = avgFreg(:,{'mouse1','pairType','module1'});
    [G, groupedAvgFreg] = findgroups(groupT);
    Func = @(X)nanmean(cat(1,X{:}),1);
    groupedAvgFreg.diffAvgF = splitapply(Func, avgFreg.diffAvgF, G);
    %% load module info from google sheet    
    moduleInfoTable = WF.Helper.ReadGoogleSheet(P.gSheet.brainAtlasLabel);
    moduleInfoTable = moduleInfoTable(:,{'num','hemisphere','moduleNameAbb'});
    % left join avgFreg and moduleInfoTable
    groupedAvgFreg = outerjoin(groupedAvgFreg, moduleInfoTable, 'LeftKeys', {'module1'}, 'RightKeys', {'num'}, 'Type', 'left', 'MergeKeys', true);
    % create a index column for avgFreg (combine mouse and session)
    % create a index column for avgFreg (combine mouse and session)
    groupedAvgFreg.index = strcat(groupedAvgFreg.mouse1, '_', groupedAvgFreg.pairType);
    % for each unique index
    indexList = unique(groupedAvgFreg.index);
    avgFregModule = table();
    for i = 1:length(indexList)
        % empty avgFregModuleTem
        avgFregModuleTem = table();
        % get thisAvgFreg
        thisAvgFreg = groupedAvgFreg(strcmp(groupedAvgFreg.index, indexList{i}),:);
        % sort thisAvgFreg by module_num which should have the same order as moduleInfoTable.num
        [~, idx] = ismember(thisAvgFreg.module1_num, moduleInfoTable.num);
        [~, idx] = sort(idx);
        thisAvgFreg = thisAvgFreg(idx,:);
        % combine data to plot
        avgFregModuleTem.avgFreg{1} = thisAvgFreg.diffAvgF';
        avgFregModuleTem.moduleNameAbb{1} = [thisAvgFreg.moduleNameAbb]';
        avgFregModuleTem.hemisphere{1} = [thisAvgFreg.hemisphere]';
        avgFregModuleTem.module_num = [thisAvgFreg.module1_num]';
        avgFregModuleTem.label{1} = strcat(avgFregModuleTem.hemisphere{1}, '-', avgFregModuleTem.moduleNameAbb{1},'(', arrayfun(@num2str, avgFregModuleTem.module_num, 'UniformOutput', 0), ')');
        avgFregModuleTem = [thisAvgFreg(1,1:2), avgFregModuleTem];
        avgFregModule(i,:) = avgFregModuleTem;
    end
    
    %% plot
    if options.sameClim
        climits_min = min(cellfun(@(x) min(x(:)), avgFregModule.avgFreg));
        climits_max = max(cellfun(@(x) max(x(:)), avgFregModule.avgFreg));
        % keep the colorbar limits symmetric
        climits = max(abs(climits_min), abs(climits_max)) * [-1, 1];
    end
    for i = progress(1:height(avgFregModule),'Title','  Plot rawMean ACT map')
        % extract info
        cMouse = avgFregModule.mouse1{i};
        cType = avgFregModule.pairType{i};

        % initialize figure
        figH = figure('Color', 'w', 'Position', get(0, 'Screensize'));
        
        % plot ROI mask
        ax1 = subplot(1,3,1);
        roiMaskReg.selectLabel = avgFregModule{1,'module_num'};
        WF.Plot.Roi.Mask.Reg(roiMaskReg,'P',P,'ax',ax1);
        
        % plot ROI average ΔF/F
        Param = struct();
        Param.ax = subplot(1,3,[2,3]);
        Param.X = avgFregModule.label{1};
        Param.Y = P.wf.frame.time;
        if options.sameClim
            Param.climits = climits;
        end
        Param.title = sprintf('%s:%s', cMouse, cType);
        Param = namedargs2cell(Param);
        WF.Plot.Roi.AvgF.RegHelper(avgFregModule.avgFreg{i},Param{:});
        exportgraphics(figH, fullfile(P.dir.actRoi.reg, sprintf('%s_%s_ActRoiReg.png', cMouse, cType)), 'Resolution', 300); 
        close(figH)
    end
end