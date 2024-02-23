function [failure_idx] = findFailureIndexAtChange(timeStep,data_len,current)
%% Constants
MICROAMP = 1e-6;
NANOAMP = 0.1e-9;

%% Function
% fig = figure(1);
% clf;
failure_idx = [];
idx = 1;
checkAlt = 0;
isCapacitiveFound = false;
while isempty(failure_idx)
    if all(current > MICROAMP)
        currentFail = current(1);
        failure_idx = find(current == currentFail);
        break;
    end
    if all(current < MICROAMP)
        if all(current > NANOAMP)
            currentFail = current(1);
            failure_idx = find(current == currentFail);
            break;
        end
    end

    while idx < data_len
        idx_final = idx + timeStep - 1;
        if idx_final > data_len
            idx_final = data_len;
        end
        interval = idx+1:idx_final;
        currentInterval = current(interval);
        if all(currentInterval > NANOAMP)
            currentStart = mean(currentInterval(1:3));
            currentLast = mean(currentInterval(end-3:end));
            isCurrentIntervalChange = currentLast > currentStart;
            coeff = polyfit(interval,currentInterval,1);
            slope = coeff(1);
            intercept = coeff(2);
            %             f = polyval(coeff,interval);
            %             plot(interval,f,'k:','LineWidth',1.5);
            currentAvg = mean(currentInterval);
            %             currentAvg_pow = floor(log10(currentAvg));
            %             slopeCheck = 1 * 10^(currentAvg_pow-powCheck);
            %             isCurrentIntervalSlope = slope > slopeCheck;
            isCurrentIntervalSlope = slope > 0;
            currentCalc = slope * interval + intercept;
            residSumOfSquares = sum((currentInterval - currentCalc).^2);
            totalSumOfSquares = sum((currentInterval - currentAvg).^2);
            residual = 1 -  residSumOfSquares/totalSumOfSquares;
            switch checkAlt
                case 0
                    try
                        [~,gof] = fit(interval',currentInterval','exp1');
                        corr = gof.rsquare;
                    catch
                        corr = 0;
                    end

                    %             valueCheck = sprintf('Value check: %.2e (start) vs. %.2e (last)',currentStart,currentLast);
                    %             slopeCheck = sprintf('Slope check %.2e A/n: %.2e A/n',powCheck,slope);
                    %             regCheck = sprintf('Regression check 0.70: %.2f',corr);
                    %             msg = sprintf('%s\n%s\n%s',valueCheck,slopeCheck,regCheck);
                    %             delete(findall(fig,'type','annotation'))
                    %             annotation(...
                    %                 fig,...
                    %                 'textbox',[.15 .6 .2 .2],...
                    %                 'String',msg,...
                    %                 'FitBoxToText','on');
                    if corr >= 0.70
                        isCapacitiveFound = true;
                    end
                case 1
                    if residual <= 0.8
                        isCapacitiveFound = true;
                    end
                case 2
                    isCapacitiveFound = true;
            end
            if isCurrentIntervalChange && isCurrentIntervalSlope && isCapacitiveFound
                failure_idx = idx;
                if idx ~= 1
                    break;
                end
            end
        end
    end
    %         drawnow;
    %         pause(0.5);
    %         hold off;
    idx = idx + timeStep;
    if idx > data_len
        checkAlt = checkAlt + 1;
        idx = 1;
        if checkAlt == 3
            break;
        end
    end
end

end
