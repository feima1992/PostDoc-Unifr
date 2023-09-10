function output = ActRoi_SetSelector(obj, inplace, varargin)
    % filters the infoTable based on the options specified in the varargin
    % inplace - if true, the infoTable is filtered in place, otherwise a new infoTable is returned
    % varargin - options to filter the infoTable, name-value pairs
    % check varargin
    obj.RegCall(mfilename);
    obj.Flow_CallMethod({'ActMap_GetFileList'});
    
    inplace = logical(inplace);

    if mod(numel(varargin), 2) ~= 0
        error('Filter: wrong number of inputs');
    end

    % filter names specified in options
    filterNames = varargin(1:2:end);
    filterValues = varargin(2:2:end);

    filedNames = {'raw', 'reg'};

    for i = 1:numel(filedNames)

        if isfield(obj.ActRoi, filedNames{i})
            infoTable = obj.ActRoi.(filedNames{i});
            % column names in infoTable
            columns = infoTable.Properties.VariableNames;
            % keep only the names that are in infoTable
            filterNames = filterNames(ismember(filterNames, columns));
            % filter infoTable
            for j = 1:numel(filterNames)
                infoTable = infoTable(ismember(infoTable.(filterNames{j}), filterValues{j}), :);
            end
            % set the infoTable
            if inplace
                obj.ActRoi.(filedNames{i}) = infoTable;
            end
            output.(filedNames{i}) = infoTable;
        end

    end

end
