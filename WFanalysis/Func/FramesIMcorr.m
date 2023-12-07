classdef FramesIMcorr < Frames
    %% Methods
    methods
        % Constructor
        function obj = FramesIMcorr(frameData, varargin)
            obj = obj@Frames(frameData, varargin{:});
        end

        % Define activation map
        function obj = CalActMap(obj, threMethod,threValue)

            arguments
                obj (1, 1) FramesIMcorr
                threMethod {mustBeMember(threMethod, {'maxPeakFrame', 'meanPeakFrame'})} = 'maxPeakFrame'
                threValue = []
            end

            switch threMethod
                case 'maxPeakFrame'

                    if isempty(threValue)
                        threValue = 0.5;
                    end

                    % find the maximum intensity of pixels in peak frame
                    upLim = max(obj.framePeak, [], 'all'); % upper limit
                    lowLim = upLim * threValue; % lower limit

                case 'meanPeakFrame'

                    if isempty(threValue)
                        threValue = 1.96;
                    end

                    % find the mean and standard deviation of pixels in peak frame
                    meanPeakFrame = mean(obj.framePeak, 'all');
                    stdPeakFrame = std(obj.framePeak, 0, 'all');
                    upLim = meanPeakFrame + threValue * stdPeakFrame; % upper limit
                    lowLim = meanPeakFrame - threValue * stdPeakFrame; % lower limit
            end

            % set pixels with intensity lower than lower limit to nan
            obj.frameData(obj.frameData < lowLim) = nan;
            % scale the intensity of pixels to [0, 1]
            obj.frameData = (obj.frameData - lowLim) / (upLim - lowLim);
        end
    end

end
