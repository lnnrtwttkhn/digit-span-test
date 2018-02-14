function waitEnter(Parameters)

% Wait for Enter keypress

while true 
    [keyIsDown,~, keyCode] = KbCheck(Parameters.device);
    keyCode(keyCode == 0) = NaN;
    [~,keyIndex] = min(keyCode);
    if logical(keyIsDown) && ismember(keyIndex,KbName('Return'))
        clear keyIsDown; clear keyIndex; clear keyCode;
        WaitSecs(0.5);
        break
    end
end

end

