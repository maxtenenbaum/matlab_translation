function [failure_idx] = findFailureIndexAtChange(timeStep,data_len,current)
%% Constants
MICROAMP = 1e-6;
NANOAMP = 0.1e-9;

%% Function
% fig = figure(1);
% clf;
failure_idx = [];
idx = 1;

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
%         idx_final = idx + timeStep - 1;
%         if idx_final > data_len
% %             idx_final = data_len;
%             interval = idx:data_len;
%         else
%             interval = idx:idx_final;
%         end
        timeEnd = idx * timeStep;
        timeStart = timeEnd - timeStep;
        timeStart_idx = find(time_fix == timeStart);
        timeEnd_idx = find(time_fix == timeEnd);
        interval = timeStart_idx:timeEnd_idx;
        currentInterval = current(interval);
%         upTo = 1:idx_final;
%         currentUpTo = current(upTo);
%         plot(upTo,currentUpTo); hold on;
%         plot(interval,currentInterval,'LineWidth',1);
        if all(currentInterval > NANOAMP)
            currentStart = mean(currentInterval(1:5));
            currentLast = mean(currentInterval(end-5:end));
            isCurrentIntervalChange = currentLast > currentStart;
            coeff = polyfit(interval,currentInterval,1);
            slope = coeff(1);
%             f = polyval(coeff,interval);
%             plot(interval,f,'k:','LineWidth',1.5);
            currentAvg = mean(currentInterval);
            currentAvg_pow = floor(log10(currentAvg));
            slopeCheck = 1 * 10^(currentAvg_pow-3);
            isCurrentIntervalSlope = slope > slopeCheck;
%             isCurrentIntervalSlope = slope > 0;
            try
                [~,gof] = fit(interval',currentInterval','exp1');
                corr = gof.rsquare;
            catch
                corr = 0;
            end
            
            isExpFit = corr > 0.70;
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
            if isExpFit
                isCapacitiveFound = true;
            end
            if isCurrentIntervalChange && isCurrentIntervalSlope && isCapacitiveFound
                failure_idx = timeStart_idx;
                if idx ~= 1
                    break;
                end
            end
        end
%         drawnow;
%         pause(0.5);
%         hold off;
        idx = idx + 1;
        if idx > data_len
            isCapacitiveFound = true;
            idx = 1;
        end
    end
end

end