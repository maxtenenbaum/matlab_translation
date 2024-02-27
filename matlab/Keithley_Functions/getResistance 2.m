function [res,res_char] = getResistance(slope)
%% Constants
KILO_MAG = 3;
MEGA_MAG = 6;
GIGA_MAG = 9;
TERA_MAG = 12;
PETA_MAG = 15;
N_TO_KILO = 1e-3;
N_TO_MEGA = 1e-6;
N_TO_GIGA = 1e-9;
N_TO_TERA = 1e-12;
N_TO_PETA = 1e-15;

%% Variables
res = abs(1 / slope);   % resistance
res_ord = floor(log10(res));

%% Function
if res_ord >= PETA_MAG
    res_scaled = res * N_TO_PETA;
    res_char = sprintf(...
        '{\\bf{\\itR}} = %.4g {\\bfP\\Omega}',...
        res_scaled);
elseif res_ord >= TERA_MAG
    res_scaled = res * N_TO_TERA;
    res_char = sprintf(...
        '{\\bf{\\itR}} = %.4g {\\bfT\\Omega}',...
        res_scaled);
elseif res_ord >= GIGA_MAG
    res_scaled = res * N_TO_GIGA;
    res_char = sprintf(...
        '{\\bf{\\itR}} = %.4g {\\bfG\\Omega}',...
        res_scaled);
elseif res_ord >= MEGA_MAG
    res_scaled = res * N_TO_MEGA;
    res_char = sprintf(...
        '{\\bf{\\itR}} = %.4g {\\bfM\\Omega}',...
        res_scaled);
elseif res_ord >= KILO_MAG
    res_scaled = res * N_TO_KILO;
    res_char = sprintf(...
        '{\\bf{\\itR}} = %.4g {\\bfk\\Omega}',...
        res_scaled);
else
    res_char = sprintf(...
        '{\\bf{\\itR}} = %.4g {\\bf\\Omega}',...
        res);
end

end