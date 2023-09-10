function Get(obj, target, varargin)

    switch target

        case 'params'
            obj.P = WF.Get.Params(varargin{1});

        case 'wfInfo'
            obj.Info.wf = WF.Get.Wf(obj.P);

        case 'bpodInfo'
            obj.Info.bpod = WF.Get.Bpod(obj.P);

        case 'refImage'

            if ~isfield(obj.Info, 'wf')
                obj.Get('wfInfo')
            end

            WF.Get.RefImage(obj.Info.wf, obj.P);

        case 'trialStat'
            
            statFile = fullfile(fileparts(obj.P.folderPath), 'trialStat.csv');

            if exist(statFile, 'file')
                stat = readtable(statFile);
                obj.Info.stat.allDir = grpstats(stat, {'mouseID', 'sessionID'}, "numel", "DataVars", "trialID", "VarNames", {'mouse', 'session', 'groupCount', 'nTrials'});
                obj.Info.stat.eachDir = grpstats(stat, {'mouseID', 'sessionID', 'mvtDir'}, "numel", "DataVars", "trialID", "VarNames", {'mouse', 'session', 'mvtDir', 'groupCount', 'nTrials'});
            end

    end

end
