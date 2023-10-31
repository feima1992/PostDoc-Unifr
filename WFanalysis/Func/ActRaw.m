classdef ActRaw< handle
    %% Properties
    properties
        param % parameters for the analysis
        wfTable % table of wf images
        bpodTable % table of bpod data
        wfBpodTable; % table of wf and bpod data combined
    end

    %% Methods
    methods
        %% Constructor
        function obj = ActRaw(param, wfTable, bpodTable)
            % validate the input
            arguments
                param (1,1) Param
                wfTable (1,1) FileTableTifWf
                bpodTable (1,1) FileTableBpod
            end
            % assign values
            obj.param = param; % parameters for the analysis
            obj.wfTable = wfTable; % table of wf images
            obj.bpodTable = bpodTable; % table of bpod data

            % load bpod data if not loaded
            if ~ismember('trial', obj.bpodTable.fileTable.Properties.VariableNames)
                obj.bpodTable.LoadFile(); % load the bpod data file
                obj.bpodTable.CleanVar({'path', 'folder', 'fileTable', 'namefull'}, 'remove'); % remove the unused variables
            end
            % combine the wf and bpod table
            obj.wfBpodTable = innerjoin(obj.wfTable.fileTable, obj.bpodTable.fileTable, 'Keys', {'mouse', 'session', 'trial'});
            % remove the trials with unmatched duration
            obj.RemoveUnmatchedDurationTrials();
            % get the path of actRaw
            obj.wfBpodTable.pathActRawMat = cellfun(@(X,Y)fullfile(param.dir.actMap.raw, [X, '_', Y, '_ACT.mat']), obj.wfBpodTable.mouse, obj.wfBpodTable.session, 'UniformOutput', false);
            obj.wfBpodTable.pathActRawTif = cellfun(@(X,Y)fullfile(param.dir.actMap.raw, [X, '_', Y, '_ACT.tif']), obj.wfBpodTable.mouse, obj.wfBpodTable.session, 'UniformOutput', false);
        end

        %% Function Align
        function Align(obj)
            % group the data by mouse and session
            groupIdx = findgroups(obj.wfBpodTable(:, {'mouse', 'session'}));
            % align the data for each group
            for i = 1:max(groupIdx)
                % get the data for the current group
                currGroup = obj.wfBpodTable(groupIdx == i, :);
                % align the data
                alignWfBpod(currGroup, obj.param);
            end

        end
        
        %% Function register with alle brain atlas
        function Reg(obj)
            % construct path to corresponding output REG files
            funcRegActName = @(x) strrep(strrep(x, 'ACT', 'REG'), 'Raw', 'Reg');
            obj.wfBpodTable.pathReg = cellfun(funcRegActName, obj.wfBpodTable.pathActRawMat, 'UniformOutput', false);
            obj.wfBpodTable.pathRegExist = cellfun(@(x) isfile(x), obj.wfBpodTable.pathReg);
            % construct path to corresponding refrerence images
            funcRefActName = @(x,y) fullfile(Param().dir.refImage, [x, '_',y, '_REF.tif']);
            obj.wfBpodTable.pathRef = cellfun(funcRefActName, obj.wfBpodTable.mouse,obj.wfBpodTable.session, 'UniformOutput', false);
            % filter out files that already have a REG file
            obj.wfBpodTable = obj.wfBpodTable(~obj.wfBpodTable.pathRegExist, :);
            % wfBpodTableForReg
            wfBpodTableForReg = unique(cleanVar(obj.wfBpodTable,{'pathActRawMat','pathActRawTif','pathRef'},'keep'));

            % for each file in filesActPath register coordinates with allen atlas
            screenSize = get(0, 'Screensize');
            guiPosition = [screenSize(1) + 100, screenSize(2) + 100, screenSize(3) - 200, screenSize(4) - 200];

            for i = 1:height(wfBpodTableForReg)

                close all
                fprintf('  Registration for \n    %s\n', wfBpodTableForReg.pathActRawMat{i})

                objReg = RegActRaw(wfBpodTableForReg.pathRef{i}, wfBpodTableForReg.pathActRawTif{i}, Param());

                set(findobj('Name', 'WF registration'), 'Position', guiPosition);
                waitfor(objReg, 'objButtonRegFlag', 1);
            end

            % close all and notify user
            close all
            fprintf('   Registration complete\n')
        end
    end

    methods(Access = private)
        %% Function remove umatched duration trials
        function obj = RemoveUnmatchedDurationTrials(obj)
            % filter out trials with duration_left and duration_right that are not matched (difference > 0.1)
            unMatchTrials = filterRow(obj.wfBpodTable, {'duration_left','duration_right'}, @(X,Y)abs(X-Y)>0.1).path;
            % move the unMatchTrials to the backup folder
            backupFolder = Param().dir.bk;
            for i = 1:length(unMatchTrials)
                try
                    movefile(unMatchTrials{i}, backupFolder);
                catch
                    continue;
                end
            end
            % remove the unMatchTrials from the table
            obj.wfBpodTable = filterRow(obj.wfBpodTable, {'path'}, @(X) ~ismember(X, unMatchTrials));

        end
    end

end
