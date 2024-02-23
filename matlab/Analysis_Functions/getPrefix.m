function [prefix,arr_fix] = getPrefix(arr)
%% Constants
PETA = 1e15;
TERA = 1e12;
GIGA = 1e9;
MEGA = 1e6;
KILO = 1e3;
BASE = 1;
MILLI = 1e-3;
MICRO = 1e-6;
NANO = 1e-9;
PICO = 1e-12;
FEMPTO = 1e-15;

%% Function
if any(arr < PICO)
    prefix = 'f';
    arr_fix = arr / FEMPTO;
elseif any(arr < NANO)
    prefix = 'p';
    arr_fix = arr / PICO;
elseif any(arr < MICRO)
    prefix = 'n';
    arr_fix = arr / NANO;
elseif any(arr < MILLI)
    prefix = 'u';
    arr_fix = arr / MICRO;
elseif any(arr < BASE)
    prefix = 'm';
    arr_fix = arr / MILLI;
elseif any(arr < KILO)
    prefix = '';
    arr_fix = arr / BASE;
elseif any(arr < MEGA)
    prefix = 'k';
    arr_fix = arr / KILO;
elseif any(arr < GIGA)
    prefix = 'M';
    arr_fix = arr / MEGA;
elseif any(arr < TERA)
    prefix = 'G';
    arr_fix = arr / GIGA;
elseif any(arr < PETA)
    prefix = 'T';
    arr_fix = arr / TERA;
elseif any(arr > PETA)
    prefix = 'P';
    arr_fix = arr / PETA;

end