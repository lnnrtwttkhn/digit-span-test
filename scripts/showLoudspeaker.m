function [Parameters] = showLoudspeaker(Parameters)

% This function shows a loudspeaker symbol.

Parameters.imageTexture = Screen('MakeTexture', Parameters.window, Parameters.theImage); % make the image into a texture
Screen('DrawTexture', Parameters.window, Parameters.imageTexture,[],[]); % draw the image to the screen with corresponding stimulus orientation
Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished
Screen('Flip',Parameters.window); % flip to the screen

end

