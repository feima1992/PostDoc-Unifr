classdef Param < handle

    properties
        folderUser
        folderParent
        folderName
        dataDrive
        select
        wfAlign
    end

    properties (Dependent)
        folderPath
        dir
        path

    end

    methods

        function obj = Param(varargin)
            %% parse input
            p = inputParser;
            addOptional(p, 'folderName', '', @ischar);
            addParameter(p, 'dataDrive', 'D', @(X)mustBeMember(X, {'D', 'E', 'F'}));
            addParameter(p, 'mouse', '', @(X)ischar(X) | isstring(X) | iscellstr(X));
            addParameter(p, 'session', '', @(X)ischar(X) | isstring(X) | iscellstr(X) | isnumeric(X));
            parse(p, varargin{:});

            %% generate parameters structure

            %% data analysis folder
            fullPath = mfilename('fullpath');
            fullPath = strsplit(fullPath, '\');
            obj.folderUser = fullfile(fullPath{1:3});
            obj.folderParent = fullfile(obj.folderUser, 'DataAnalysis');
            obj.folderName = p.Results.folderName;
            obj.dataDrive = p.Results.dataDrive;

            %% select mouse and session
            obj.select.mouse = p.Results.mouse;

            if isnumeric(p.Results.session)
                obj.select.session = cellstr(string(p.Results.session));
            else
                obj.select.session = p.Results.session;
            end

            %% widefield alignment
            obj.wfAlign.reUseMask = true;
            obj.wfAlign.alignWin = [-1, 1.5]; % window for alignment, relative to the trigger onset
            obj.wfAlign.frameRate = 20; % frame rate of the WF video
            obj.wfAlign.frameTime = obj.wfAlign.alignWin(1):1 / obj.wfAlign.frameRate:obj.wfAlign.alignWin(2); % time line of the aligned WF video
        end

        %% Get methods for dependent properties
        % folderPath
        function folderPath = get.folderPath(obj)
            folderPath = fullfile(obj.folderParent, obj.folderName);
        end

        % dir
        function dir = get.dir(obj)

            dir.bp = fullfile(obj.folderUser, 'Bpod\Bpod Local\Data\'); % directory of bpod data
            dir.wf = fullfile([obj.dataDrive, ':\Data\'], 'WFrecordings'); % directory of widefield video recordings
            dir.bk = fullfile([obj.dataDrive, ':\Data\'], 'WFrecordings\FakeSubject'); % directory of backup folderPath to store wf recordings with problem
            dir.refImage = fullfile(obj.folderParent, 'Utilities\RefImage'); % directory of reference images
            dir.regXy = fullfile(obj.folderParent, 'Utilities\RegXy'); % directory of coordinate registration files
            dir.actMap.raw = fullfile(obj.folderPath, 'ActMap\Raw'); % directory of activation maps: raw
            dir.actMap.reg = fullfile(obj.folderPath, 'ActMap\Reg'); % directory of activation maps: registered
            dir.actMap.rawDiff = fullfile(obj.folderPath, 'ActMap\RawDiff'); % directory of activation maps: raw difference
            dir.actMap.regDiff = fullfile(obj.folderPath, 'ActMap\RegDiff'); % directory of activation maps: registered difference
            dir.actRoi.raw = fullfile(obj.folderPath, 'ActRoi\Raw'); % directory of activation ROI: raw
            dir.actRoi.reg = fullfile(obj.folderPath, 'ActRoi\Reg'); % directory of activation ROI: registered
            dir.actRoi.rawDiff = fullfile(obj.folderPath, 'ActRoi\RawDiff'); % directory of activation ROI: raw difference
            dir.actRoi.regDiff = fullfile(obj.folderPath, 'ActRoi\RegDiff'); % directory of activation ROI: registered difference
        end

        % path
        function path = get.path(obj)
            path.abmTemplate = fullfile(obj.folderParent, 'Utilities', 'ABMTemplate.tif'); % path of the template for allen mouse brain atlas
            path.roiMaskForAlignTrig = fullfile(obj.folderParent, 'Utilities', 'roiMask.mat'); % path of the mask for ROI analysis
            path.fileTableTifWfTemp = fullfile(obj.folderParent, 'Utilities', 'fileTableTifWfTemp.txt'); % path of temporary widefield video file information table
        end

        %% creat folder
        function CreatDir(obj)
            %% creat obj.dir folders if not exist
            if ~exist(obj.folderPath, 'dir')
                mkdir(obj.folderPath);
            end

            dirPath = nestStruct2table(obj.dir).value;

            for i = 1:length(dirPath)

                if ~exist(dirPath{i}, 'dir')
                    mkdir(dirPath{i});
                end
            end
        end

    end

end
