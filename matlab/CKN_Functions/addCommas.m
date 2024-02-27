function num_new = addCommas(num)
try
    if num == 0
        num_new = '0';
    else
        numOfPlaces = floor(log10(num));
        numOfSeps = floor(numOfPlaces/3);
        num_char = num2str(num);

        num_char_reverse = reverse(num_char);
        decimalPoint_idx = strfind(num_char_reverse,'.');

        commaCount = 0;
        for commaNum = 1:numOfSeps
            idx = 3 * commaNum + commaCount;
            if ~isempty(decimalPoint_idx)
                idx = idx + decimalPoint_idx;
            end
            idx_char = num_char_reverse(1:idx);
            idx_after = num_char_reverse(idx+1:end);
            num_char_reverse = strcat(idx_char,',',idx_after);
            commaCount = commaCount + 1;
        end
        num_new = reverse(num_char_reverse);
    end
catch
    num_new = num2str(num);
end