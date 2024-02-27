function error_char = errorCheck(gpib)

% Check for errors on the instrument
fprintf(gpib,'SYSTem:ERRor?');
error_str = fgetl2(gpib);
if ~contains2(error_str, 'No error')
    fprintf('\n');
    error_char = ['Instrument Error: ', error_str];
    error(error_char);
end

end