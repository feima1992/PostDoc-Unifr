function ConfigPackagePath(packagePath)
    % add subfolders of a package to the matlab path
    % packagePath: path to the package folder

    % get the package path
    packagePath = regexp(packagePath,'.*\+.*?(?<=\\)','match','once');
    subFolders = dir([packagePath,'**']);
    subFolders = subFolders([subFolders.isdir]);
    subFolders = subFolders(~ismember({subFolders.name},{'.','..'}));
    % filter subfolders that is not a package or class folder
    subFolders = subFolders(~cellfun(@(x) contains(x,'+'),{subFolders.name}));
    subFolders = subFolders(~cellfun(@(x) contains(x,'@'),{subFolders.name}));
    % full path of subfolders
    subFolders = fullfile({subFolders.folder},{subFolders.name});
    % add subfolders to the matlab path
    addpath(subFolders{:});
end