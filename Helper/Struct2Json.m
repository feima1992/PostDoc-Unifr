function j = Struct2Json(s,options)
%STRUCT2JSON Convert a MATLAB struct to a JSON string
% options:
%   'filePath' - path to file to write to

% validate input
arguments
    s struct
    options.filePath = ''
end

% convert to json
j = jsonencode(s);
if ~isempty(options.filePath)
    % write to file
    fid = fopen(options.filePath,'w');
    fprintf(fid,'%s',j);
    fclose(fid);
end
end