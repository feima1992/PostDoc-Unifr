function GetParams(obj,options)
% GetParams
% DESCRIPTION: Get the parameters from the parameters file
% INPUT:
% obj.pName: string pattern to find the parameters file. string, default ''
% options: options for finding the parameters file.
% options.process: flag to process the parameters file. logical, default false
% OUTPUT:
% p: parameters structure

% validate the input
arguments
    obj
    options.process (1,1) logical = false
    options.updateFolder (1,:) char = ''
end
if isempty(obj.p)
   obj.p = LoadParams(obj);

else
    if ~ isempty(options.updateFolder)
        obj.p = LoadParams(obj,'updateFolder',options.updateFolder);
    end
    if options.process
        ProcessParams(obj.p);
    end
end

end
function p = LoadParams(obj,options)
% validate inputs
arguments
    obj
    options.updateFolder (1,:) char ='';
end
% find the parameters file
fullPath = mfilename('fullpath'); % get the directory of the current file
dirFile = fileparts(fileparts(fileparts(fullPath))); % get the directory of the parent directory
paramFile = WF.Helper.FindFiles(dirFile,{'parameters','.m', obj.pName}); % search for the parameters file

% check the parameters find results
if isempty(paramFile) || length(paramFile)>1
    error('The parameters file is not found or there are multiple parameters files.');
end

% evaluate the parameters file to get the parameters
if isempty(options.updateFolder)
    p = feval(paramFile(1).name);
else
    mapForEachMvtDir = obj.p.act.flag.mapForEachMvtDir;
    p = feval(paramFile(1).name, options.updateFolder);
    p.act.flag.mapForEachMvtDir = mapForEachMvtDir;
end
fprintf('>>> Loading parameters from %s.\n',paramFile(1).namefull);

end

function p = ProcessParams(p)
% if animal is not specified, use all animals
if isempty(p.select.animal.proprioception)
    p.select.stimType.proprioception = 1;

    % find all the animal folders in p.dir.wf
    animalFolders = dir([p.dir.wf,filesep,'*']);
    animalFolders = {animalFolders.name};
    p.select.animal.proprioception = animalFolders(contains(animalFolders,'m'));

    if isempty(p.select.animal.proprioception)
        error('No animal folder is found in the folder %s.',p.dir.wf);
    end

end
% animal can start as a capital letter or a lower case letter
p.select.animal.proprioception = [upper(p.select.animal.proprioception),lower(p.select.animal.proprioception)];
p.select.animal.vibration = [upper(p.select.animal.vibration),lower(p.select.animal.vibration)];
p.select.animal.whisker = [upper(p.select.animal.whisker),lower(p.select.animal.whisker)];

% session can be 6 digits or 8 digits
p.select.session.proprioception = [p.select.session.proprioception,p.select.session.proprioception+20000000];
p.select.session.vibration = [p.select.session.vibration,p.select.session.vibration+20000000];
p.select.session.whisker = [p.select.session.whisker,p.select.session.whisker+20000000];

% create the user directory if it does not exist
if ~exist(p.folder,'dir')
    mkdir(p.folder);
end

% create folder for all fields of p.dir
for i = fieldnames(p.dir)'
    if ~exist(p.dir.(i{1}),'dir')
        mkdir(p.dir.(i{1}));
    end
end

% check if p.path.(X) is an existing file, if not, error message
for i = fieldnames(p.path)'
    if ~exist(p.path.(i{1}),'file')&& ~isempty(p.path.(i{1})) && ~contains(p.path.(i{1}),'.txt')
        error(['The file ',p.path.(i{1}),' does not exist.']);
    end
end
end