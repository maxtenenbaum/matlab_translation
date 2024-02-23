function [numOfSteps,lastVoltageStep] = getNumOfSteps(lifetime,timeStep_s,voltageStep)

numOfSteps = floor(lifetime / timeStep_s) + 1;
lastVoltageStep = (numOfSteps - 1) * voltageStep;

end