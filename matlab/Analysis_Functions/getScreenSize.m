function [screenWidth,screenHeight] = getScreenSize()
%% Function
screenSize = get(0,'screensize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);

end