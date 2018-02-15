function [response,acc] = getResponse(Parameters,digitSequence,cond)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

DrawFormattedText(Parameters.window,'Eingabe:','center',Parameters.centerY - Parameters.textSize,Parameters.colorBlack); % draw 'Eingabe:'
useKbCheck = true;
message = ' ';
numDigits = length(digitSequence); % get the number of digits in the current digit sequence
response = GetEchoString(Parameters.window,message,...
    Parameters.centerX - numDigits * Parameters.textSize / 2.5,...
    Parameters.centerY,...
    Parameters.colorBlack,Parameters.colorWhite,...
    useKbCheck,Parameters.device);
clear keyIsDown; clear keyIndex; clear keyCode;
Screen('Flip',Parameters.window); % flip after response entry
response = str2double(response); % convert response from string to double

% FLIP DIGIT SEQUENCE IF IT IS THE BACKWARD CONDITION 
if cond == 2
    digitSequence = fliplr(digitSequence);
else
end

% GET ACCURACY SCORE
if isequal(response,str2double(sprintf('%d',digitSequence)))
    acc = 1;
elseif ~isequal(response,str2double(sprintf('%d',digitSequence)))
    acc = 0;
end



end

