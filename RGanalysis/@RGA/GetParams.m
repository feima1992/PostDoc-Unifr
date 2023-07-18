%% GetParams
function p = GetParams()
    % getParams: get the parameters for the WFA class
    % p: struct with the parameters
    % load global parameters
    fullPath = mfilename('fullpath');
    % get the directory of this file
    [dirFile,~,~] = fileparts(fileparts(fileparts(fullPath)));
    paramFile = F.FindFiles(dirFile,{'parameters','.m'});
    if isempty(paramFile)
        error('Cannot find parameters file');
    elseif length(paramFile) > 1
        error('More than one parameters file found');
    else
        % add the directory of the parameters file to the path
        addpath(paramFile(1).folder)
        p = eval(paramFile(1).name);
    end
end	