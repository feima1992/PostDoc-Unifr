function P = Params(paramName)

    arguments
        paramName (1, :) char = 'basic'
    end

    %% Get the parameters file and load it

    % search for the parameters file with the given parameter name
    fullPath = mfilename('fullpath');
    dirFile = regexp(fullPath, '.*?\+.*?(?<=\\)', 'match', 'once');
    paramFile = findFile(dirFile, {'.m', paramName},{},'table_output',false);
    paramFile = paramFile(ismember({paramFile.name},paramName));
    % load the parameters file
    if isempty(paramFile)
        error('No parameters file found with the name "%s"', paramName)
    elseif length(paramFile) > 1
        error('Multiple parameters files found with the name "%s"', paramName)
    else
        P = feval(paramFile(1).name);
    end

end
