%% Digit Span Test
% written by Lennart Wittkuhn | Max Planck Research Group NeuroCode | 2018
% Max Planck Institute (MPI) for Human Development, Berlin, Germany

% This is a computerized version of the Digit-Span Test.

% This task only runs on Mac OSX, since it makes use of the MATLAB
% system('say','') command, which is only supported by Mac OSX

function digitSpanTest
%%  SET ALL TASK INDEPENDENT PARAMETERS:

% CLEAN UP:
close all; clear variables; clc;

% DEFINE THE BASELOCATION DEPENDING ON THE PLATFORM:
if ismac
    Parameters.baseLocation = '~'; % base location for Mac
elseif ispc
    f = msgbox('This is a Windows machine! The task only runs on Mac OSX!','Error','error');
    uiwait(f);
    return
end

% ASK WHETHER SYSTEM LANGUAGE HAS BEEN CHANGED TO GERMAN?
choice = questdlg('Is the system language set to German?',...
    'Warning!', ...
    'No','Yes','Yes');
if strcmp(choice,'No')
    return
elseif strcmp(choice,'Yes')
end

% IDENTIFY COMPUTER
Parameters.computer = computer; % save information about computer
Parameters.hostName = char(getHostName(java.net.InetAddress.getLocalHost));

% CHANGE FILE PATH IF YOU ARE RUNNING ON LAB MAC COMPUTER AND ADD
% PSYCHTOOLBOX TO THE MATLAB PATH:
if strcmp(Parameters.hostName,'nrcd-osx-404169') || strcmp(Parameters.hostName,'NRCD-OSX-404170.local') % lab mac minis
    Parameters.baseLocation = fullfile('/Users','Shared','NeuroCode_Lennart'); % name of the scanner trigger box
    addpath(genpath('/Users/Shared/Psychtoolbox')); % add PsychToolbox to Matlab search path
end

Parameters.osName = OSName; % save information about operating system
Parameters.matlabVersion = ['R' version('-release')]; % save information about operating systemversion('-release')

% SET ALL NECESSARY TASK PATHS AND GET SYSTEM INFORMATION
Parameters.pathTask = fullfile(Parameters.baseLocation,'Seafile','digitSpanTest'); % path to the task folder
Parameters.pathScripts = fullfile(Parameters.pathTask,'scripts'); % path to the task folder
Parameters.pathStimuli = fullfile(Parameters.pathTask,'stimuli'); % path to the task folder
Parameters.pathData = fullfile(Parameters.pathTask,'data'); % path to the data directory
cd(Parameters.pathScripts) % set the current directory to the script folder

% INITALIZE RANDOM NUMBER GENERATOR:
rng(sum(100*clock)); % initalize random number generator

% SCREEN SETTINGS:
Parameters.screenId = max(Screen('Screens')); % choose the highest screen
[Parameters.screenSize(1), Parameters.screenSize(2)] = Screen('WindowSize',Parameters.screenId); % get the screen size
Parameters.screenResolution = [Parameters.screenSize(1) Parameters.screenSize(2)]; % get screen resolution
Parameters.centerX = Parameters.screenSize(1)/2; % get center of x-axis
Parameters.centerY = Parameters.screenSize(2)/2; % get center of y-axis

% GET LOUDSPEAKER IMAGE
Parameters.Parameters.theImageLocation = fullfile(Parameters.pathStimuli,'speaker.png'); % create image path
Parameters.theImage = imread(Parameters.Parameters.theImageLocation); % read the image

% SET TEXT PARAMETERS:
Parameters.textSize = 50; % text size
Parameters.textFont = 'Helvetica'; % font type
Parameters.textWrap = 70; % text wrap factor
Parameters.colorBlack = [0 0 0]; % color black
Parameters.colorWhite = [256 256 256]; % color white

% SET KEY PARAMETERS:
KbName('UnifyKeyNames'); % used for cross-platform compatibility of keynaming
Parameters.keyTargets = [KbName('1!'),KbName('2@'),KbName('3#'),KbName('4$'),...
    KbName('5%'),KbName('6^'),KbName('7&'),KbName('8*'),KbName('9('),KbName('Return'),KbName('DELETE')]; % list all relevant keys here
Parameters.keyList = zeros(1,256); % initalize a key list of 256 zeros
Parameters.keyList(Parameters.keyTargets) = 1; % set keys of interest to 1

% GET THE DEVICE NUMBER:
[Parameters.deviceKeyNames,Parameters.deviceNames] = GetKeyboardIndices; % get a list of all devices connected
if ismac
    if strcmp(Parameters.hostName,'lip-osx-003854') % lennarts mac book
        Parameters.deviceString = 'Apple Internal Keyboard / Trackpad'; % name of the keyboard
    elseif strcmp(Parameters.hostName,'nrcd-osx-404169') % lab mac mini 1
        Parameters.deviceString = 'Magic Keyboard with Numeric Keypad'; % name of the keyboard
    elseif strcmp(Parameters.hostName,'NRCD-OSX-404170.local') % lab mac mini 2
        Parameters.deviceString = 'Apple Keyboard'; % name of the keyboard
    end
    Parameters.device = 0;
    for k = 1:length(Parameters.deviceNames) % for each possible device
        if strcmp(Parameters.deviceNames{k},Parameters.deviceString) % compare the name to the name you want
            Parameters.device = Parameters.deviceKeyNames(k); % grab the correct id, and exit loop
            break;
        end
    end
    if Parameters.device == 0 %%error checking
        error('No device by that name was detected');
    end
    clear k;
elseif ispc
    Parameters.device =  Parameters.deviceKeyNames;
end

%% INPUT SUBJECT INFO
while true
    
    % ENTER PARTICIPANT DETAILS:
    prompt = {'id','age','gender'}; % define the prompts
    dlgTitle = 'Subject Info'; % define the dialog box title
    numLines = 1; % define the number of response lines
    defaultAns = {'99999','99999','m/f'}; % define the default answers
    Parameters.subjectInfo = inputdlg(prompt,dlgTitle,numLines,defaultAns); % create and show dialog box
    
    % TURN INTO A STRUCTURE ARRAY:
    Parameters.subjectInfo = cell2struct(Parameters.subjectInfo,prompt,1);
    
    % CHECK IF DATA ALREADY EXISTS
    Parameters.dirData = dir(Parameters.pathData); % get info from stimulus files directory
    Parameters.dirData = Parameters.dirData(~ismember({Parameters.dirData.name},{'.','..','.DS_Store','.Rhistory'})); % get rid of '.', '..' and '.DS_Store' in d.name
    Parameters.dataFiles = transpose({Parameters.dirData.name}); % list all stimuli names (inbcluding .jpg extension)
    
    % CHECK INPUT DETAILS:
    if numel(Parameters.subjectInfo.id) ~= 5 % if ID has not been correctly specified
        f = msgbox('ID must contain 5 digits!','Error','error');
        uiwait(f);
    elseif any(contains(Parameters.dataFiles,Parameters.subjectInfo.id))
        f = msgbox('ID has already been used! Please choose another ID!','Error','error');
        uiwait(f);
    elseif ~strcmp(Parameters.subjectInfo.gender,'m') && ~strcmp(Parameters.subjectInfo.gender,'f') % if ID has not been correctly specified
        f = msgbox('Gender must be either m or f','Error','error');
        uiwait(f);
    else
        
        % CHECK INPUT ONCE MORE:
        choice = questdlg([{'Would you like to continue with this setup?'};...
            {''};...
            strcat(transpose(prompt),{': '},struct2cell(Parameters.subjectInfo))], ...
            'Continue?', ...
            'Cancel','OK','OK');
        
        % END LOOP IF ALL DETAILS ARE CORRECT:
        if strcmp(choice,'OK')
            Parameters.subjectInfo.age = str2double(Parameters.subjectInfo.age); % turn into double
            break
        else
            f = msgbox('Process aborted: Please start again!','Error','error');
            uiwait(f);
        end
        
    end
end

%% DEFINE TASK SETTINGS:
Parameters.nTrials = 14;
Parameters.numCond = 2;
Parameters.digitInterval = 0.5;

% CREATE AND SAVE DATA FILE
Data = table; % % initalize
Data.id = repmat(Parameters.subjectInfo.id,Parameters.nTrials * Parameters.numCond,1);
Data.cond = transpose(repelem(1:2,Parameters.nTrials)); % initalize
Data.trial = repmat(transpose(1:Parameters.nTrials),Parameters.numCond,1); % initalize
Data.digits = {...
    [5 8 2];...
    [6 9 4];...
    [6 4 3 9];...
    [7 2 8 6];...
    [4 2 7 3 1];...
    [7 5 8 3 6];...
    [6 1 9 4 7 3];...
    [3 9 2 4 8 7];...
    [5 9 1 7 4 2 8];...
    [4 1 7 9 3 8 6];...
    [5 8 1 9 2 6 4 7];...
    [3 8 2 9 5 1 7 4];...
    [2 7 5 8 6 2 5 8 4];...
    [7 1 3 9 4 2 5 6 8];...
    [2 4];...
    [5 8];...
    [6 2 9];...
    [4 1 5];...
    [3 2 7 9];...
    [4 9 6 8];...
    [1 5 2 8 6];...
    [6 1 8 4 3];...
    [5 3 9 4 1 8];...
    [7 2 4 8 5 6];...
    [8 1 2 9 3 6 5];...
    [4 7 3 9 1 2 8];...
    [9 4 3 7 6 2 5 8];...
    [7 2 8 1 9 6 5 3];...
    };
Data.response = nan(Parameters.nTrials*Parameters.numCond,1); % initalize
Data.acc =  nan(Parameters.nTrials*Parameters.numCond,1); % initalize

%% START PSYCHTOOLBOX

% PSYCHTOOLBOX SETTINGS:
Screen('Preference','SkipSyncTests',1); % for maximum accuracy and reliability
Screen('Preference','VisualDebugLevel',3);
Screen('Preference','SuppressAllWarnings',1);
Screen('Preference','Verbosity',0);
set(0,'DefaultFigureWindowStyle','normal');
Screen('Preference', 'TextRenderer', 1)
Screen('Preference','TextEncodingLocale','de_DE.ISO8859-1'); % set text encoding preference to UTF-8
Screen('Preference', 'TextAlphaBlending', 0);
clear ans % clear unnecessasary variables

% OPEN TASK WINDOW
Parameters.window = Screen('OpenWindow', Parameters.screenId); % open screen
Priority(MaxPriority(Parameters.window)); % raise Matlab to realtime-priority mode to get the highest suitable priority
Screen('TextFont', Parameters.window, Parameters.textFont); % select specific text font
Screen('TextSize', Parameters.window, Parameters.textSize); % select specific text size
ListenChar(2); % makes it so characters typed do not show up in the command Parameters.window
HideCursor(); % hides the cursor
RestrictKeysForKbCheck(Parameters.keyTargets);
Parameters.flipInterval = Screen('GetFlipInterval', Parameters.window); % get the monitor flip interval

% START SCREEN: WELCOME PARTICIPANTS TO THE EXPERIMENT
DrawFormattedText(Parameters.window,'Willkommen zur Aufgabe','center',Parameters.centerY-Parameters.textSize * 2,Parameters.colorBlack);
DrawFormattedText(Parameters.window,'"Zahlenreihen merken"','center','center',Parameters.colorBlack);
DrawFormattedText(Parameters.window, 'Start mit der Enter-Taste','center',Parameters.screenSize(2)-Parameters.textSize,Parameters.colorBlack);
Screen('Flip',Parameters.window); % flip to the screen
waitEnter(Parameters); % wait for enter keypress

% GET START TIME:
Parameters.tStart = tic; % get start time 

%% INSTRUCTIONS FORWARD AND BACKWARD

for cond = 1:Parameters.numCond
    
    if cond == 1
        
        % DRAW INSTRUCTIONS FOR FORWARD CONDITION:
        DrawFormattedText(Parameters.window,'Instruktionen: Zahlenreihen vorwaerts','center',Parameters.textSize * 2,Parameters.colorBlack);
        DrawFormattedText(Parameters.window,strjoin({'Der Computer wird Ihnen einige Zahlen vorlesen.',...
            'Wenn er fertig ist, geben Sie bitte die Zahlen in die Tastatur ein.',...
            'Nutzen Sie dafuer bitte ausschliesslich die Zahlenreihe (oben auf der Tastatur)',...
            'und nicht den Zahlenblock (rechts auf der Tastatur).',...
            'Sie koennen Ihre Eingabe mithilfe der Loeschen-Taste korrigieren.',...
            'Bitte bestaetigen Sie Ihre Eingabe mit der Enter-Taste.',...
            'Druecken Sie bitte die Enter-Taste fuer ein Beispiel.'}),'center','center',Parameters.colorBlack,Parameters.textWrap);
        DrawFormattedText(Parameters.window, 'Start mit der Enter-Taste','center',Parameters.screenSize(2)-Parameters.textSize,Parameters.colorBlack);
        Screen('Flip',Parameters.window); % flip to the screen
        
    elseif cond == 2
        
        DrawFormattedText(Parameters.window,'Instruktionen: Zahlenreihen rueckwaerts','center',Parameters.textSize * 2,Parameters.colorBlack);
        DrawFormattedText(Parameters.window,strjoin({'Der Computer wird Ihnen wieder einige Zahlen nennen.',...
            'Dieses mal geben Sie jedoch bitte die Zahlen in der umgekehrten Reihenfolge (von hinten nach vorne) in die Tastatur ein.',...
            'Druecken Sie bitte die Enter-Taste fuer ein Beispiel.'}),'center','center',Parameters.colorBlack,Parameters.textWrap);
        DrawFormattedText(Parameters.window, 'Start mit der Enter-Taste','center',Parameters.screenSize(2)-Parameters.textSize,Parameters.colorBlack);
        Screen('Flip',Parameters.window); % flip to the screen
        
    end
    
    % WAIT FOR ENTER KEYPRESS:
    waitEnter(Parameters);
    
    while true
        
        % SHOW LOUDSPEAKER
        [Parameters] = showLoudspeaker(Parameters);
        
        % READ DIGITS:
        if cond == 1
            digitSequence = [8 2 3]; % define the current digit sequence
        elseif cond == 2
            digitSequence = [7 1 9]; % define current sequence
        end
        readDigits(digitSequence,Parameters.digitInterval); % let readDigits read the digits
        
        % GET PARTICIPANT ENTRY:
        [response,acc] = getResponse(Parameters,digitSequence,cond);
        
        % SHOW FEEDBACK
        if acc == 1 % response is correct
            DrawFormattedText(Parameters.window,'Das war richtig!','center','center',Parameters.colorBlack);
            DrawFormattedText(Parameters.window, 'Weiter mit der Enter-Taste','center',Parameters.screenSize(2)-Parameters.textSize,Parameters.colorBlack);
            Screen('Flip',Parameters.window); % flip after response entry
            waitEnter(Parameters); % wait for enter key press
            break
        elseif acc == 0 % response is wrong
            DrawFormattedText(Parameters.window,'Das war leider falsch.','center','center',Parameters.colorBlack);
            DrawFormattedText(Parameters.window, 'Wiederholen mit der Enter-Taste','center',Parameters.screenSize(2)-Parameters.textSize,Parameters.colorBlack);
            Screen('Flip',Parameters.window); % flip after response entry
            waitEnter(Parameters); % wait for enter key press
        end
        
    end
    
end

%% START BEFORE MAIN TASK

DrawFormattedText(Parameters.window,strjoin({'Jetzt beginnt das Hauptexperiment.'...
    'Sie bearbeiten zuerst die Aufgabenbedingung "Zahlenreihen vorwaerts".',...
    'Danach bearbeiten Sie die Aufgabenbedingung "Zahlenreihen ruckwaerts".',...
    'Bitte beachten Sie, dass die Zahlenreihen im Verlauf des Experiments laenger werden.',...
    'Immer wenn Sie Ihre Eingabe mit Enter bestaetigen, geht es automatisch mit der naechsten Zahlenreihe weiter.',...
    'Ausserdem erhalten Sie keine Rueckmeldung mehr, ob Ihre Antwort richtig oder falsch war.'}),'center','center',Parameters.colorBlack,Parameters.textWrap);
DrawFormattedText(Parameters.window, 'Start mit der Enter-Taste','center',Parameters.screenSize(2)-Parameters.textSize,Parameters.colorBlack);
Screen('Flip',Parameters.window); % flip to the screen
waitEnter(Parameters); % wait for enter key press


%% MAIN TASK

message = {'Bitte Zahlenreihen vorwaerts wiedergeben.';'Bitte Zahlenreihen rueckwaerts wiedergeben.'};

for cond = 1:Parameters.numCond % loop through both conditions
   
    % SHOW START SCREEN:
    DrawFormattedText(Parameters.window,'Hauptexperiment','center',Parameters.textSize * 2,Parameters.colorBlack);
    DrawFormattedText(Parameters.window,message{cond},'center','center',Parameters.colorBlack); % draw fixation cross to screen
    DrawFormattedText(Parameters.window, 'Start mit der Enter-Taste','center',Parameters.screenSize(2)-Parameters.textSize,Parameters.colorBlack);
    Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished
    Screen('Flip',Parameters.window); % flip to the screen
    waitEnter(Parameters); % wait for Enter keypress
    
    % START MAIN TASK LOOP
    trial = 1;
    while true
        % SHOW LOUDSPEAKER
        [Parameters] = showLoudspeaker(Parameters);
        % READ DIGITS:
        readDigits(Data.digits{Data.cond == cond & Data.trial == trial},Parameters.digitInterval); % let readDigits read the digits
        % GET PARTICIPANT ENTRY:
        [response,acc] = getResponse(Parameters,Data.digits{Data.cond == cond & Data.trial == trial},cond);
        Data.response(Data.cond == cond & Data.trial == trial) = response; % save response
        Data.acc(Data.cond == cond & Data.trial == trial) = acc; % save accuracy score
        % DECIDE WHETHER TO STOP OR TO CONTINUE:
        if mod(trial,2) == 0 && nansum(Data.acc(Data.cond == cond & ismember(Data.trial,trial-1:trial))) == 0 || trial == Parameters.nTrials
            break
        else
            trial = trial + 1;
        end
    end
end

%% END OF THE EXPERIMENT

% SHOW SCREEN: END OF THE EXPERIMENT
DrawFormattedText(Parameters.window,'Ende der Aufgabe.','center',Parameters.textSize * 2,Parameters.colorBlack);
DrawFormattedText(Parameters.window,double('Vielen Dank fuer Ihre Teilnahme.'),'center',Parameters.textSize * 4,Parameters.colorBlack);
DrawFormattedText(Parameters.window, 'Bitte wenden Sie sich an die Versuchsleitung.','center',Parameters.screenSize(2)-Parameters.textSize,Parameters.colorBlack);
Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished
Screen('Flip',Parameters.window); % flip to the screen
KbPressWait; % wait for button press to continue

% SAVE DATA AND SHOW SCORE:
save(fullfile(Parameters.pathData,['DigitSpan_',Parameters.subjectInfo.id,'.mat']),'Data','Parameters'); % save subject data
fprintf('Data saved successfully!\n')
fprintf('Total score: %d\n',nansum(Data.acc));

% FINISH PSYCHTOOLBOX
ListenChar(0); % makes it so characters typed do show up in the command Parameters.window
ShowCursor(); % show the cursor
Screen('CloseAll'); % close screen
RestrictKeysForKbCheck; % reset the keyboard input checking for all keys
Priority(0); % disable realtime mode

% GET TOTAL TIME AND DISPLAY:
Parameters.tEnd = toc(Parameters.tStart); % get stop time
fprintf('Total duration: %d minutes and %f seconds\n',floor(Parameters.tEnd/60),rem(Parameters.tEnd,60));


end

