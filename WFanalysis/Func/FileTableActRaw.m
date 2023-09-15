classdef FileTableActRaw < FileTableAct

    %% Methods
    methods
        %% Constructor
        function obj = FileTableActRaw(varargin)
            % Call superclass constructor
            obj = obj@FileTableAct(varargin{:});
            % Filter rows to only include raw data
            obj.Filter('actType', 'Raw');
        end

         %% Function register with alle brain atlas
        function Reg(obj)
            % construct path to corresponding output REG files
            funcRegActName = @(x) strrep(strrep(x, 'ACT', 'REG'), 'Raw', 'Reg');
            obj.fileTable.pathReg = cellfun(funcRegActName, obj.fileTable.path, 'UniformOutput', false);
            obj.fileTable.pathRegExist = cellfun(@(x) isfile(x), obj.fileTable.pathReg);
            % construct path to corresponding refrerence images
            funcRefActName = @(x) fullfile(Param().dir.refImage, strrep(x, 'ACT.mat', 'REF.tif'));
            obj.fileTable.pathRef = cellfun(funcRefActName, obj.fileTable.namefull, 'UniformOutput', false);
            % filter out files that already have a REG file
            obj.fileTable = obj.fileTable(~obj.fileTable.pathRegExist, :);

            % for each file in filesActPath register coordinates with allen atlas
            screenSize = get(0, 'Screensize');
            guiPosition = [screenSize(1) + 100, screenSize(2) + 100, screenSize(3) - 200, screenSize(4) - 200];

            for i = 1:height(obj.fileTable)

                close all
                fprintf('  Registration for \n    %s\n', obj.fileTable.path{i})

                objReg = RegActRaw(obj.fileTable.pathRef{i}, strrep(obj.fileTable.path{i},'.mat','.tif'), Param());

                set(findobj('Name', 'WF registration'), 'Position', guiPosition);
                waitfor(objReg, 'objButtonRegFlag', 1);
            end
        end
    end
    
end