function ActRoi_PlotAvgFrawTuning(obj, options)
% validate inputs
arguments
    obj
    options.roiId (1,:) double = 1:size(obj.ActRoi.mask.raw.rectangleXy,1)
    options.frameId (1,1) double = 28
    options.sameLim (1, 1) logical = true
end
% register method call
obj.RegCall(mfilename);
% run dependent methods
obj.Flow_CallMethod({'ActMap_GetFileList',1});
obj.Flow_CallMethod({'ActMap_GetBregmaXy'; 'ActRoi_SetMask'; 'ActRoi_ApplyMask'; 'ActRoi_SetSessionPair'});

% remove mvtDir 0, which is all movement direction data
actRaw = obj.ActRoi.Raw;
actRaw(actRaw.mvtDir==0,:) = [];

% check wether 8 mvtDir are present
mvtDir = unique(actRaw.mvtDir);
if  ~ all(ismember(1:8,mvtDir))
    % if not, return
    error('Not 8 mvtDir data');
end

% calculate axis limits
climits_min = min(cellfun(@(x) min(x(:)), actRaw.avgF));
climits_max = max(cellfun(@(x) max(x(:)), actRaw.avgF));
AxesLimits = [climits_min, climits_max];


% for each mouse, session

groupIDs = findgroups(actRaw(:,{'mouse','session'}));
groupID = unique(groupIDs);


for i = 1:length(groupID)
    
    % get the actRoi for this mouse, session
    actRawMouseSession = actRaw(groupIDs==groupID(i),:);
    actRawMouseSession = sortrows(actRawMouseSession,{'mvtDir'});
    
    % skip if not all 8 mvtDir are present
    if ~ all(ismember(1:8,actRawMouseSession.mvtDir))
        fprintf('   Not 8 mvtDir: %s-%s\n', actRawMouseSession.mouse{1}, actRawMouseSession.session{1});
    end
        
    % extract information
    cMouse = actRawMouseSession.mouse{1};
    cGroup = actRawMouseSession.group{1};
    cSession = actRawMouseSession.session{1};
    cPhase = actRawMouseSession.phase{1};
    
    % get the rawF for this mouse, session
    actRawFMouseSession = cat(3, actRawMouseSession.avgF{:});
    actRawFMouseSession = squeeze(actRawFMouseSession(options.frameId,options.roiId,:));
    
    % for each roi in this mouse, session plot the mvtdir tuning
    
    for j = 1:size(actRawFMouseSession,1)
        % creat a new figure
        figure('Color','white','Position',[100,100,800,800]')
        % tiled layout
        tiledlayout(1,2,'TileSpacing','Compact','Padding','Compact');
        % plot the roi mask
        nexttile;
        obj.ActRoi_PlotMaskRaw(gca,'roiId',j);
        % plot the tuning spider plot
        nexttile;
        Param = struct();
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
        
        % axis limits
        if options.sameLim
            Param.AxesLimits = AxesLimits;
        end
        
        Param = namedargs2cell(Param);
        SpiderPlotAvgFraw(actRawFMouseSession(j,:), Param{:});
        % save the figure
        saveas(gcf,fullfile(obj.filepath.fig,['ActRoi_PlotAvgFrawTuning_' cMouse '_' cSession,'_roi' num2str(j) '.png']));
        close gcf
    end
end

end