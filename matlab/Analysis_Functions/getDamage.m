function damage = getDamage(lifetime,timeStep_s,voltageStep,n)

%% Variables
syms k;
[numOfSteps,~] = getNumOfSteps(lifetime,timeStep_s,voltageStep);
numOfFullSteps = numOfSteps - 1;

%% Function
sumEqn = (voltageStep * (k-1))^n;
summation = timeStep_s * symsum(sumEqn,k,1,numOfFullSteps);
% lastTimeStep = lifetime - (timeStep_s * numOfFullSteps);
lastTimeStep = rem(lifetime,timeStep_s);
lastDamageStep = lastTimeStep * (voltageStep * numOfFullSteps)^n;
damage = summation + lastDamageStep;

end