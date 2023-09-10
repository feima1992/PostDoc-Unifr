function RegDiff(avgFreg,P, options)
    arguments
        avgFreg table
        P (1,1) struct
        options.sameClim (1,1) logical = true
    end
    %% load module info from google sheet    
    moduleInfoTable = WF.Helper.ReadGoogleSheet(P.gSheet.brainAtlasLabel);
    moduleInfoTable = moduleInfoTable(:,{'num','hemisphere','moduleNameAbb'});
    % left join avgFreg and moduleInfoTable
    avgFreg = outerjoin(avgFreg, moduleInfoTable, 'LeftKeys', {'module1'}, 'RightKeys', {'num'}, 'Type', 'left', 'MergeKeys', true);
    % create a index column for avgFreg (combine mouse and session)
    avgFreg.index = strcat(avgFreg.mouse1, '_', avgFreg.session2, '-', avgFreg.session1);
    % for each unique index
    indexList = unique(avgFreg.index);
    avgFregModule = table();
    for i = 1:length(indexList)
        % empty avgFregModuleTem
        avgFregModuleTem = table();
        % get thisAvgFreg
        thisAvgFreg = avgFreg(strcmp(avgFreg.index, indexList{i}),:);
        % sort thisAvgFreg by module_num which should have the same order as moduleInfoTable.num
        [~, idx] = ismember(thisAvgFreg.module1_num, moduleInfoTable.num);
        [~, idx] = sort(idx);
        thisAvgFreg = thisAvgFreg(idx,:);
        % combine data to plot
        avgFregModuleTem.avgFreg{1} = cell2mat(thisAvgFreg.diffAvgF');
        avgFregModuleTem.moduleNameAbb{1} = [thisAvgFreg.moduleNameAbb]';
        avgFregModuleTem.hemisphere{1} = [thisAvgFreg.hemisphere]';
        avgFregModuleTem.module_num = [thisAvgFreg.module1_num]';
        avgFregModuleTem.label{1} = strcat(avgFregModuleTem.hemisphere{1}, '-', avgFregModuleTem.moduleNameAbb{1},'(', arrayfun(@num2str, avgFregModuleTem.module_num, 'UniformOutput', 0), ')');
        avgFregModuleTem = [thisAvgFreg(1,[1:11,14:24]), avgFregModuleTem];
        avgFregModule(i,:) = avgFregModuleTem;
    end
    
    %% plot
    if options.sameClim
        climits_min = min(cellfun(@(x) min(x(:)), avgFregModule.avgFreg));
        climits_max = max(cellfun(@(x) max(x(:)), avgFregModule.avgFreg));
        % keep the colorbar limits symmetric
        climits = max(abs(climits_min), abs(climits_max)) * [-1, 1];
    end
    for i = progress(1:height(avgFregModule),'Title','  Plot regDiff ACT map')
        % extract info
        cMouse = avgFregModule.mouse1{i};
        cSession1 = avgFregModule.session1{i};
        cSession2 = avgFregModule.session2{i};
        cAvgF = avgFregModule.avgFreg{i};

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
        Param.title = sprintf('%s:%s-%s', cMouse, cSession2, cSession1);
        Param = namedargs2cell(Param);
        WF.Plot.Roi.AvgF.RegHelper(cAvgF,Param{:});
        exportgraphics(figH, fullfile(P.dir.actRoi.regDiff, sprintf('%s_%s-%s_ActRoiReg.png', cMouse, cSession1, cSession2)), 'Resolution', 300); 
        close(figH)
    end
end