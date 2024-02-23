function dist_arr = getDistribution2(arr)
%% Constants
TEST_THRESH = 2;

%% Variables
dist_arr = {};

%% Tests
% Normal
% test = 'Normal QQ';
% normQQ = sprintf('%s %s',name,test);
% figure('Name',normQQ);
% norm = makedist('Normal');
% qqplot(data,norm);
% title(test);
[isNotNorm_L,pNormL] = lillietest(arr,'Distribution','normal');
[isNotNorm_AD,pNormAD] = adtest(arr,'Distribution','norm');
[isNotNorm_KS,pNormKS] = kstest(arr);
[isNotNorm_JB,pNormJB] = jbtest(arr);
isNorm_L = ~isNotNorm_L;
isNorm_AD = ~isNotNorm_AD;
isNorm_KS = ~isNotNorm_KS;
isNorm_JB = ~isNotNorm_JB;
doesPassNorm = isNorm_L + isNorm_AD + isNorm_KS + isNorm_JB;
if doesPassNorm >= TEST_THRESH
    fprintf('Data is in normal distribution.\n');
    if isNorm_L
        fprintf('\tPassed Lilliefors normal test, p = %f\n',pNormL);
    end
    if isNorm_AD
        fprintf('\tPassed Anderson-Darling normal test, p = %f\n',pNormAD);
    end
    if isNorm_KS
        fprintf('\tPassed One-sample Kolmogorov-Smirnov normal test., p = %fn',pNormKS);
    end
    if isNorm_JB
        fprintf('\tPassed Jarque-Bera normal test, p = %f\n',pNormJB);
    end
    dist_arr_alloc = [dist_arr,'norm'];
    dist_arr = dist_arr_alloc;
else
    fprintf('Data is NOT in normal distribution.\n');
end

% Lognormal
% test = 'Lognormal QQ';
% lognormQQ = sprintf('%s %s',name,test);
% figure('Name',lognormQQ);
% lognorm = makedist('Lognormal');
% qqplot(data,lognorm);
% title(test);
logData = log10(arr);
[isNotLognorm_L,pLognorm_L] = lillietest(logData,'Distribution','normal');
[isNotLognorm_AD,pLognorm_AD] = adtest(arr,'Distribution','logn');
[isNotLognorm_KS,pLognorm_KS] = kstest(logData);
[isNotLognorm_JB,pLognorm_JB] = jbtest(logData);
isLognorm_L = ~isNotLognorm_L;
isLognorm_AD = ~isNotLognorm_AD;
isLognorm_KS = ~isNotLognorm_KS;
isLognorm_JB = ~isNotLognorm_JB;
doesPassLognorm = isLognorm_L + isLognorm_AD + isLognorm_KS + isLognorm_JB;
if doesPassLognorm >= TEST_THRESH
    fprintf('Data is in lognormal distribution.\n');
    if isLognorm_L
        fprintf('\tPassed Lilliefors lognormal test, p = %f\n',pLognorm_L);
    end
    if isLognorm_AD
        fprintf('\tPassed Anderson-Darling lognormal test, p = %f\n',pLognorm_AD);
    end
    if isLognorm_KS
        fprintf('\tPassed One-sample Kolmogorov-Smirnov lognormal test, p = %f\n',pLognorm_KS);
    end
    if isLognorm_JB
        fprintf('\tPassed Jarque-Bera lognormal test,  p = %f\n',pLognorm_JB);
    end
    dist_arr_alloc = [dist_arr,'logn'];
    dist_arr = dist_arr_alloc;
else
    fprintf('Data is NOT in lognormal distribution.\n');
end
    
% Weibull
% test = 'Weibull QQ';
% wbQQ = sprintf('%s %s',name,test);
% figure('Name',wbQQ);
% wb = makedist('Weibull');
% qqplot(data,wb);
% title(test);
[isNotWeibull_L,pWeibull_L] = lillietest(log10(arr),'Distribution','extreme value');
[isNotWeibull_AD,pWeibull_AD] = adtest(arr,'Distribution','weibull');
isWeibull_L = ~isNotWeibull_L;
isWeibull_AD = ~isNotWeibull_AD;
doesPassWeibull = isWeibull_L + isWeibull_AD;
if doesPassWeibull >= TEST_THRESH
    fprintf('Data is in Weibull distribution.\n');
    if isWeibull_L
        fprintf('\tPassed Lilliefors Weibull test, p = %f\n',pWeibull_L);
    end
    if isWeibull_L
        fprintf('\tPassed Anderson-Darling Weibull test, p = %f\n',pWeibull_AD);
    end
    dist_arr_alloc = [dist_arr,'weibull'];
    dist_arr = dist_arr_alloc;
else
    fprintf('Data is NOT in Weibull distribution.\n');
end

if length(dist_arr) == 1
    dist_arr = dist_arr{1};
end

end