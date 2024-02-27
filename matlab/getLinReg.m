function [slope,intercept,r2] = getLinReg(x,y)
len = length(x);
x_data = zeros(len,1);
y_data = zeros(len,1);
x_data(:) = x(:);
y_data(:) = y(:);

% Linear Regression
linReg = polyfit(x_data,y_data,1);
slope = linReg(1);
intercept = linReg(2);
fit_data = polyval(linReg,x_data);

% Coefficient of Determination
% Sum of Squares
% y_mean = mean(y_data);
% meanDiff = y_data - y_mean;
% squares = meanDiff .^ 2;
% sumOfSquares = sum(squares);   % Total Sum-Of-Squares
numOfValues = length(y_data);
y_var = var(y);
sumOfSquares = (numOfValues - 1) * y_var;
% Residual sum of squares
resid = y_data-fit_data;
residSquares = resid .^ 2;
residSumSquares = sum(residSquares); % Residual Sum-Of-Squares
r2 = 1 - residSumSquares/sumOfSquares; 

end