function readDigits(digitSequence,interval)

% This function reads the numbers of a vector with an interval of 1 second
% WARNING: Only works on Mac OSX!
% Reason: Use of the system() Matlab command

% INPUT:
% Any sequence of numbers as numeric values in a vector
% For example: digitSequence = [1 2 3]

% OUTPUT: none

for digit = 1:length(digitSequence) % loop through the sequence
    currentDigit = num2str(digitSequence(digit)); % get current digit as string
    system(['say ',currentDigit]); % let system read the digit
    WaitSecs('UntilTime',GetSecs + interval); % one second interval between digits
end

end

