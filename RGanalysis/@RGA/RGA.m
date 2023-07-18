classdef RGA < handle
    methods(Static)
        %% GetParams
        p = GetParams()
        %% GetFileList
        fileList = GetFileList(target)
        %% GetTrialInfo
        trialInfoTable = GetSessionInfo(p)
        %% RegMatch
        Reg = RegMatch(strCell, patternID)
    end
end