function LimbReachGrasp

    global BpodSystem
    
    %% Setup (runs once before the first trial)
    MaxTrials = 10000; % Set to some sane value, for preallocation
    
    %% Resolve WavePlayer USB port
    if (isfield(BpodSystem.ModuleUSB, 'WavePlayer1'))
        WavePlayerUSB = BpodSystem.ModuleUSB.WavePlayer1;
    else
        error('Error: To run this protocol, you must first pair the WavePlayer1 module with its USB port. Click the USB config button on the Bpod console.')
    end
    
    %% Resolve AnalogInput USB port
    if (isfield(BpodSystem.ModuleUSB, 'AnalogIn1'))
        AnalogInputUSB = BpodSystem.ModuleUSB.AnalogIn1;
    else
        error('Error: To run this protocol, you must first pair the AnalogInput1 module with its USB port. Click the USB config button on the Bpod console.')
    end
    
    %% Define parameters and trial structure
    S = BpodSystem.ProtocolSettings; % Loads settings file chosen in launch manager into current workspace as a struct called 'S'
    if isempty(fieldnames(S))  % If chosen settings file was an empty struct, populate struct with default settings
        % Define default settings here as fields of S (i.e S.InitialDelay = 3.2)
        % Note: Any parameters in S.GUI will be shown in UI edit boxes. 
        % See ParameterGUI plugin documentation to show parameters as other UI types (listboxes, checkboxes, buttons, text)
        
        S.GUI.TrialNum = 0; % Trial number counter
        S.GUIMeta.TrialNum.Style = 'text';

        S.GUI.TrialNumAttempt = 0; % Trial number with >=1 attempt (mosue reached out the slit but failed to grasp the water droplet)
        S.GUIMeta.TrialNumAttempt.Style = 'text';
        
        S.GUI.TrialNumSuccess = 0; % Trial number with >=1 success (mouse touched the water tube and grasped the water droplet)
        S.GUIMeta.TrialNumSuccess.Style = 'text';
        
        S.GUI.WaterPulse_T = 0.05; % How long the water valve opens to deliver reward
        S.GUI.RemoveWater_T = 0.12; % How long the water valve opens to remove water droplet in case of no grasp
        S.GUI.Beep_T = 0.3; % How long the beep lasts to indicate reward delivery
        
        S.GUI.GraspMustReach = 1;
        S.GUIMeta.GraspMustReach.Style = 'checkbox';
        S.GUI.MergeReach_T = 0.1; % Merge reaches detected that close enough (threshould)
        
        S.GUI.WithholdWin_T = 3;    % Pre-reward withhold duration when mouse is required not to rechout the slit
        S.GUI.ReachWin_T = 5;    % Time window waiting for mouse to reach or grasp
        S.GUI.GraspWin_T = 1;   % Time window to detect grasp of the water droplet (timer starts from the first detected grasp)
        S.GUI.GraspWin_Type = 1;
        S.GUIMeta.GraspWin_Type.Style = 'popupmenu';
        S.GUIMeta.GraspWin_Type.String = {'Absolute', 'Interval'};
        
        S.GUI.StartProtocol = 'startFunction'; % Start protocol button
        S.GUIMeta.StartProtocol.Style = 'pushbutton';

        S.GUIPanels.CueAndReward = {'WaterPulse_T', 'RemoveWater_T', 'Beep_T'};
        S.GUIPanels.TaskParameters = {'WithholdWin_T', 'ReachWin_T', 'GraspWin_T','GraspWin_Type'};
        S.GUIPanels.TaskInformation = {'TrialNum', 'TrialNumAttempt', 'TrialNumSuccess', 'StartProtocol'};   
        S.GUIPanels.PlotParameters = {'GraspMustReach','MergeReach_T'};
    end
    
    %% Define trial/data variables
    BpodSystem.Data.AIdata.Data = cell(MaxTrials,1); % The logged analog data will be stored here (or write directly to disk at every trial end)
    BpodSystem.Data.AIdata.fnameBase = 'C:\...'; % The logged analog data will be stored here (or write directly to disk at every trial end)
    
    [~,CurrentDataFile,~] = fileparts( BpodSystem.Path.CurrentDataFile);
    mnInd = strfind(CurrentDataFile, '_');
    mouseName = CurrentDataFile(1:mnInd(1)-1);
    
    if ~exist(['C:\Data\' mouseName], 'dir')
        mkdir('C:\Data\', mouseName)
    end
    BpodSystem.Data.CurrData.fnameBase = ['C:\Data\' mouseName '\' mouseName '_'];
    BpodSystem.Data.CurrData.fileH = [];
    
    BpodSystem.Data.trialOutcomes.Types = {'TimeOut';'Reach';'Grasp'};
    BpodSystem.Data.trialOutcomes.Outcome = cell(MaxTrials,1);
    BpodSystem.Data.trialOutcomes.OutcomeIdx = [];
    
    BpodSystem.Data.Flags.startProtocol = 0;

    %% Initialize plots and start USB connections to any modules
    
    nPlottedTrials = 100;  
    nWindow = 20;
    
    % Outcome plot
    BpodSystem.ProtocolFigures.OutcomeFig = figure('Color', 'w', 'Position', [950 850 1000 200], 'name', 'Trial outcomes', 'numbertitle','off', 'MenuBar', 'none');
    BpodSystem.GUIHandles.OutcomeAxes = axes('Parent', BpodSystem.ProtocolFigures.OutcomeFig);
    BpodSystem.GUIHandles.OutcomePlots = plot(BpodSystem.GUIHandles.OutcomeAxes, 1:nPlottedTrials, nan(3,nPlottedTrials), 'o', 'MarkerEdgeColor', 'none', 'MarkerSize', 8);
    set(BpodSystem.GUIHandles.OutcomePlots, {'MarkerFaceColor'}, {[1 0 0]; [0 0 0.75];[0 0.75 0]});
    
    set(BpodSystem.GUIHandles.OutcomeAxes, 'Box', 'off', 'TickDir', 'out', 'TickLength', [0.01 0.01], 'XLim', [0 nPlottedTrials+1], 'YLim', [0 3], 'YTick', 1:3, 'YTickLabel', BpodSystem.Data.trialOutcomes.Types);
    xlabel(BpodSystem.GUIHandles.OutcomeAxes, 'Trial number');
    
    % Moving average plot
    BpodSystem.ProtocolFigures.MoveAvgFig = figure('Color', 'w', 'Position', [1450 600 400 200], 'name', 'Moving average of % outcomes', 'numbertitle','off', 'MenuBar', 'none');
    BpodSystem.GUIHandles.MoveAvgAxes = axes('Parent', BpodSystem.ProtocolFigures.MoveAvgFig);
    BpodSystem.GUIHandles.MoveAvgPlots = plot(BpodSystem.GUIHandles.MoveAvgAxes, 1:nPlottedTrials, nan(3,nPlottedTrials), 'LineWidth', 2);
    set(BpodSystem.GUIHandles.MoveAvgPlots, {'Color'}, {[1 0 0]; [0 0 0.75];[0 0.75 0]});
    
    set(BpodSystem.GUIHandles.MoveAvgAxes, 'Box', 'off', 'TickDir', 'out', 'TickLength', [0.01 0.01], 'XLim', [0 nPlottedTrials+1], 'YLim', [-0.1 1.1], 'YTick', 0:0.25:1, 'YTickLabel', 0:25:100);
    xlabel(BpodSystem.GUIHandles.MoveAvgAxes, 'Trial number');
    
    % Reach and Grasp plot
    BpodSystem.ProtocolFigures.ReachGraspFig = figure('Color', 'w', 'Position', [0 850 850 200], 'name', 'Reach and Grasp', 'numbertitle','off', 'MenuBar', 'none');
    BpodSystem.GUIHandles.ReachGraspAxes = axes('Parent', BpodSystem.ProtocolFigures.ReachGraspFig);
    BpodSystem.GUIHandles.ReachGraspAxes.Box = 'off';
    BpodSystem.GUIHandles.ReachGraspAxes.YAxis.Visible = 'off';
    for i = 1:50
        BpodSystem.GUIHandles.(['ReachPlotsP',num2str(i)]) = patch(BpodSystem.GUIHandles.ReachGraspAxes, [nan,nan,nan,nan], [0 1 1 0],'g','FaceAlpha',0.5,'EdgeColor','none');
    end
    for i = 1:50
        BpodSystem.GUIHandles.(['GraspPlotsP',num2str(i)]) = patch(BpodSystem.GUIHandles.ReachGraspAxes, [nan,nan,nan,nan], [0 1 1 0],'r','FaceAlpha',0.5,'EdgeColor','none');
    end
    BpodSystem.GUIHandles.ReachGraspAxes.XLabel.String = 'Time (s)';
    legend([BpodSystem.GUIHandles.ReachPlotsP1,BpodSystem.GUIHandles.GraspPlotsP1],{'Reach','Grasp'},'Location','bestoutside');

    % Initialize parameter GUI plugin
    BpodParameterGUI('init', S); 

    %% Create an instance of the wavePlayer module
    W = BpodWavePlayer(WavePlayerUSB);
    
    % SF = W.Info.maxSamplingRate; % Use max supported sampling rate
    SF=5000;
    pulse_T  = 0.25; % 250 ms
    Wave_MoveTrig = [5*ones(1, SF*pulse_T) 0];      % signal for out move
    Wave_HomeTrig = [-5*ones(1, SF*pulse_T) 0];    % signal for home move
    
    % Program wave server
    W.SamplingRate = SF;
    W.TriggerMode = 'Master';   % triggers can force-start a new wave during playback
    W.TriggerProfileEnable = 'Off';
    W.OutputRange = '-5V:5V';
    W.loadWaveform(1, Wave_MoveTrig);
    W.loadWaveform(2, Wave_HomeTrig);
    
    % Set Bpod serial message library with correct codes to trigger waves X on analog output channels X
    analogPortIndex = find(strcmp(BpodSystem.Modules.Name, 'WavePlayer1'));
    if isempty(analogPortIndex)
        error('Error: Bpod WavePlayer module not found. If you just plugged it in, please restart Bpod.')
    end
    
    ResetSerialMessages;
    LoadSerialMessages('WavePlayer1', ['P' 1 0], 11);   % ['P' channel waveID-1]
    LoadSerialMessages('WavePlayer1', ['P' 1 1], 22);
    
    %% Create an instance of the analogIn module
    AI = BpodAnalogIn(AnalogInputUSB);
    AI.nSamplesToLog = inf;
    AI.SamplingRate = 1000;
    AI.nActiveChannels = 5;
    for k=1:AI.nActiveChannels
        AI.InputRange{1,k}='-5V:5V';
    end
    
    LoadSerialMessages('AnalogIn1', ['L' 1], 88);    % start logging
    LoadSerialMessages('AnalogIn1', ['L' 0], 99);    % stop logging
    
    
    % Set soft code handler to trigger sounds
    BpodSystem.SoftCodeHandlerFunction = '';
    

    while ~BpodSystem.Data.Flags.startProtocol
        % waiting for button push
        pause(0.1);
    end
    
    
    %% Main loop (runs once per trial)
    for currentTrial = 1:MaxTrials
        S.GUI.TrialNum = currentTrial; % Update the trial counter
        S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
        
        %% Assemble state machine
        sma = NewStateMachine();
        sma = SetGlobalTimer(sma, 'TimerID', 1, 'Duration', S.GUI.ReachWin_T); % Reach window timer
        sma = SetGlobalTimer(sma, 'TimerID', 2, 'Duration', S.GUI.GraspWin_T); % Grasp window timer

        %% Start trial, start the trial by sending a trigger to start camera recording
        sma = AddState(sma, 'Name', 'StartTrial', ... 
        'Timer', 0.5,...
        'StateChangeConditions', {'Tup', 'WithholdReach'},...
        'OutputActions', {});

        %% Withhold, before giving reward, mouse is required not to rechout the slit
        sma = AddState(sma, 'Name', 'WithholdReach', ...
        'Timer', S.GUI.WithholdWin_T,...
        'StateChangeConditions', {'Tup', 'GiveReward', 'Port4In', 'WithholdReachReset'},...
        'OutputActions', {});
        sma = AddState(sma, 'Name', 'WithholdReachReset', ...
        'Timer', 0.1,...
        'StateChangeConditions', {'Tup','WithholdReach'},...
        'OutputActions', {});

        %% Reward states, give reward and beep and trigger camera recording
        sma = AddState(sma, 'Name', 'GiveReward', ... 
            'Timer', S.GUI.WaterPulse_T,...
            'StateChangeConditions', {'Tup', 'RewardBeep','Port4In', 'WaitForGrasp','Port3In', 'Grasp'},...
            'OutputActions', {'Valve2', 1,'PWM2', 255,'Wire1', 1, 'GlobalTimerTrig', 1});
        sma = AddState(sma, 'Name', 'RewardBeep', ...
            'Timer',  S.GUI.Beep_T-S.GUI.WaterPulse_T,...
            'StateChangeConditions', {'Tup', 'WaitForReach','Port4In', 'WaitForGrasp','Port3In', 'Grasp'},...
            'OutputActions', {'PWM2', 255});

        %% Mouse reach out the slit
        sma = AddState(sma, 'Name', 'WaitForReach', ...
        'Timer',0,...
        'StateChangeConditions', {'GlobalTimer1_End', 'RemoveWaterDroplet','Port4In', 'WaitForGrasp','Port3In', 'Grasp'},...
        'OutputActions', {});

        %% Grasp water, mouse grasped the water droplet
        sma = AddState(sma, 'Name', 'WaitForGrasp', ...
        'Timer',0,...
        'StateChangeConditions', {'GlobalTimer1_End', 'RemoveWaterDroplet','Port4Out','WaitForReach','Port3In','Grasp'},...
        'OutputActions', {});
        
        switch S.GUI.GraspWin_Type
            case 2
                sma = AddState(sma, 'Name', 'Grasp', ...
                'Timer',0,...
                'StateChangeConditions', {'Port3Out', 'GraspReset'},...
                'OutputActions', {'GlobalTimerTrig', 2});
                sma = AddState(sma, 'Name', 'GraspReset', ...
                'Timer', 0,...
                'StateChangeConditions', {'Port3In','Grasp','GlobalTimer2_End','PreFinalState'},...
                'OutputActions', {});
            case 1
                sma = AddState(sma, 'Name', 'Grasp', ...
                'Timer',0,...
                'StateChangeConditions', {'Tup', 'GraspHelper'},...
                'OutputActions', {'GlobalTimerTrig', 2});
                sma = AddState(sma, 'Name', 'GraspHelper', ...
                'Timer',0,...
                'StateChangeConditions', {'Port3Out', 'GraspReset','GlobalTimer2_End','PreFinalState'},...
                'OutputActions', {});
                sma = AddState(sma, 'Name', 'GraspReset', ...
                'Timer', 0,...
                'StateChangeConditions', {'Port3In','GraspHelper','GlobalTimer2_End','PreFinalState'},...
                'OutputActions', {});
        end
        
        %% Remove water droplet, remove the water droplet in case of no grasp
       sma = AddState(sma, 'Name', 'RemoveWaterDroplet', ...
        'Timer',S.GUI.RemoveWater_T,...
        'StateChangeConditions', {'Tup', 'PreFinalState'},...
        'OutputActions', {'Valve2', 1});
        %% Wrap up states, pre final state and final state
        
        sma = AddState(sma, 'Name', 'PreFinalState', ... % pre last state allowing for more current data logging post reward
            'Timer',  0.5,...
            'StateChangeConditions', {'Tup', 'FinalState'},...
            'OutputActions', {});
        
        sma = AddState(sma, 'Name', 'FinalState', ... % last state 
            'Timer',  0.1,...
            'StateChangeConditions', {'Tup', 'exit'},...
            'OutputActions', {});
        
        
        SendStateMatrix(sma); % Send state machine to the Bpod state machine device
        RawEvents = RunStateMatrix; % Run the trial and return events
        %--- Package and save the trial's data, update plots
        if ~isempty(fieldnames(RawEvents)) % If you didn't stop the session manually mid-trial
            BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Adds raw events to a human-readable data struct
            BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
            
            trialOutcome = [num2str(~isnan(BpodSystem.Data.RawEvents.Trial{1,currentTrial}.States.WaitForGrasp(1))),....
                num2str(~isnan(BpodSystem.Data.RawEvents.Trial{1,currentTrial}.States.Grasp(1)))];
            switch trialOutcome
                case '11'
                    outcomeIdx = 3;
                    S.GUI.TrialNumSuccess = S.GUI.TrialNumSuccess + 1;
                    S.GUI.TrialNumAttempt = S.GUI.TrialNumAttempt + 1;
                case '01'
                    outcomeIdx = 3;
                    S.GUI.TrialNumSuccess = S.GUI.TrialNumSuccess + 1;
                    S.GUI.TrialNumAttempt = S.GUI.TrialNumAttempt + 1;
                case '10'
                    outcomeIdx = 2;
                    S.GUI.TrialNumAttempt = S.GUI.TrialNumAttempt + 1;
                case '00'
                    outcomeIdx = 1;
            end

            S = BpodParameterGUI('sync', S);
             
            BpodSystem.Data.trialOutcomes.Outcome(currentTrial,1) = BpodSystem.Data.trialOutcomes.Types(outcomeIdx,1);
            BpodSystem.Data.trialOutcomes.OutcomeIdx = [BpodSystem.Data.trialOutcomes.OutcomeIdx; false(1,3)];
            BpodSystem.Data.trialOutcomes.OutcomeIdx(end, outcomeIdx) = true;
    
            SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
            
            %--- Typically a block of code here will update online plots using the newly updated BpodSystem.Data
            
            MovAvg = sum(BpodSystem.Data.trialOutcomes.OutcomeIdx(max(1,currentTrial-nWindow+1):currentTrial,:),1)/min(currentTrial,nWindow);
            outcomeVals = nan(length(BpodSystem.Data.trialOutcomes.Types),1);
            outcomeVals(outcomeIdx,1) = outcomeIdx;
    
            ydatMovAvg = get(BpodSystem.GUIHandles.MoveAvgPlots, 'ydata');
            ydatMovAvg = cell2mat(ydatMovAvg);
            
            ydat = get(BpodSystem.GUIHandles.OutcomePlots, 'ydata');
            ydat = cell2mat(ydat);
            
            if currentTrial<=nPlottedTrials
                ydatMovAvg(:,currentTrial) = MovAvg';
                set(BpodSystem.GUIHandles.MoveAvgPlots, {'ydata'}, num2cell(ydatMovAvg,2));
                
                ydat(:,currentTrial) = outcomeVals;
                set(BpodSystem.GUIHandles.OutcomePlots, {'ydata'}, num2cell(ydat,2));
            else
                set(BpodSystem.GUIHandles.MoveAvgPlots, {'ydata'}, num2cell([ydatMovAvg(:,2:end) MovAvg'],2));
                set(BpodSystem.GUIHandles.OutcomePlots, {'ydata'}, num2cell([ydat(:,2:end) outcomeVals],2));
                
                set(BpodSystem.GUIHandles.OutcomeAxes, 'XLim', [currentTrial-nPlottedTrials currentTrial+1]);
                set(BpodSystem.GUIHandles.MoveAvgAxes, 'XLim', [currentTrial-nPlottedTrials currentTrial+1]);
                
                set(BpodSystem.GUIHandles.OutcomePlots, 'xdata', currentTrial-nPlottedTrials+1:currentTrial);
                set(BpodSystem.GUIHandles.MoveAvgPlots, 'xdata', currentTrial-nPlottedTrials+1:currentTrial);
            end
            
            % reach and grasp plot
            % reset all patches
            for kk = 1:50
                set(BpodSystem.GUIHandles.(['ReachPlotsP',num2str(kk)]), 'xdata', [nan,nan,nan,nan]);
                set(BpodSystem.GUIHandles.(['GraspPlotsP',num2str(kk)]), 'xdata', [nan,nan,nan,nan]);
            end
            % replace patches with new data
            switch outcomeIdx
            case 3
                reachStartTimes = BpodSystem.Data.RawEvents.Trial{1,currentTrial}.Events.Port4In;
                if isfield(BpodSystem.Data.RawEvents.Trial{1,currentTrial}.Events, 'Port4Out')
                    reachEndTimes = BpodSystem.Data.RawEvents.Trial{1,currentTrial}.Events.Port4Out;
                else
                    reachEndTimes = nan;
                end
                graspStartTimes = BpodSystem.Data.RawEvents.Trial{1,currentTrial}.Events.Port3In;
                if isfield(BpodSystem.Data.RawEvents.Trial{1,currentTrial}.Events, 'Port3Out')
                    graspEndTimes = BpodSystem.Data.RawEvents.Trial{1,currentTrial}.Events.Port3Out;
                else
                    graspEndTimes = nan;
                end
                startTimes = BpodSystem.Data.RawEvents.Trial{1,currentTrial}.States.RewardBeep(2);
                endTimes = max(BpodSystem.Data.RawEvents.Trial{1,currentTrial}.States.GraspReset(:));
                reachStartTimes = reachStartTimes(reachStartTimes<endTimes & reachStartTimes>startTimes);
                reachEndTimes = reachEndTimes(reachEndTimes<endTimes & reachEndTimes>startTimes);
                graspStartTimes = graspStartTimes(graspStartTimes<endTimes & graspStartTimes>startTimes);
                graspEndTimes = graspEndTimes(graspEndTimes<endTimes & graspEndTimes>startTimes);
                if length(reachStartTimes) > length(reachEndTimes)
                    reachEndTimes = [reachEndTimes, endTimes];       
                end
                if length(graspStartTimes) > length(graspEndTimes)
                    graspEndTimes = [graspEndTimes, endTimes];       
                end
                
                % assume reach based on grasp
                if S.GUI.GraspMustReach
                    reachStartTimes = sort([reachStartTimes,graspStartTimes]);
                    reachEndTimes = sort([reachEndTimes,graspEndTimes]);
                end
                % megre consective reaches if they are close enough
                if S.GUI.MergeReach_T > 0
                    for i = 1:length(reachStartTimes)
                        if i == 1
                            newReachStartTimes = reachStartTimes(i);
                            newReachEndTimes = reachEndTimes(i);
                        else
                            if reachStartTimes(i) - newReachEndTimes(end) < S.GUI.MergeReach_T
                                newReachEndTimes(end) = reachEndTimes(i);
                            else
                                newReachStartTimes = [newReachStartTimes,reachStartTimes(i)];
                                newReachEndTimes = [newReachEndTimes,reachEndTimes(i)];
                            end
                        end
                    end
                    reachStartTimes = newReachStartTimes;
                    reachEndTimes = newReachEndTimes;
                end


                for ii = 1:min(length(reachStartTimes),50)
                    set(BpodSystem.GUIHandles.(['ReachPlotsP',num2str(ii)]), 'xdata', [reachStartTimes(ii), reachStartTimes(ii), reachEndTimes(ii), reachEndTimes(ii)]);
                end
                for jj = 1:min(length(graspStartTimes),50)
                    set(BpodSystem.GUIHandles.(['GraspPlotsP',num2str(jj)]), 'xdata', [graspStartTimes(jj), graspStartTimes(jj), graspEndTimes(jj), graspEndTimes(jj)]);
                end
            case 2
                reachStartTimes = BpodSystem.Data.RawEvents.Trial{1,currentTrial}.Events.Port4In;
                if isfield(BpodSystem.Data.RawEvents.Trial{1,currentTrial}.Events, 'Port4Out')
                    reachEndTimes = BpodSystem.Data.RawEvents.Trial{1,currentTrial}.Events.Port4Out;
                else
                    reachEndTimes = nan;
                end
                endTimes = max(BpodSystem.Data.RawEvents.Trial{1,currentTrial}.States.WaitForGrasp(:));
                reachStartTimes = reachStartTimes(reachStartTimes<endTimes);
                reachEndTimes = reachEndTimes(reachEndTimes<endTimes);
                if length(reachStartTimes) > length(reachEndTimes)
                    reachEndTimes = [reachEndTimes, endTimes];       
                end
                
                                % megre consective reaches if they are close enough
                if S.GUI.MergeReach_T > 0
                    for i = 1:length(reachStartTimes)
                        if i == 1
                            newReachStartTimes = reachStartTimes(i);
                            newReachEndTimes = reachEndTimes(i);
                        else
                            if reachStartTimes(i) - newReachEndTimes(end) < S.GUI.MergeReach_T
                                newReachEndTimes(end) = reachEndTimes(i);
                            else
                                newReachStartTimes = [newReachStartTimes,reachStartTimes(i)];
                                newReachEndTimes = [newReachEndTimes,reachEndTimes(i)];
                            end
                        end
                    end
                    reachStartTimes = newReachStartTimes;
                    reachEndTimes = newReachEndTimes;
                end
                
                for ii = 1:min(length(reachStartTimes),50)
                    set(BpodSystem.GUIHandles.(['ReachPlotsP',num2str(ii)]), 'xdata', [reachStartTimes(ii), reachStartTimes(ii), reachEndTimes(ii), reachEndTimes(ii)]);
                end
            end
        end
        
        
        
        %--- This final block of code is necessary for the Bpod console's pause and stop buttons to work
        HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
        if BpodSystem.Status.BeingUsed == 0
            ManualOverride('OW', 2);
            pause(0.1);
            ManualOverride('OW', 2);
            return
        end
    end
    
    
    
    
    