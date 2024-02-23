function data_fix = makeDataUnique(data,eps)
% Function to adjust duplicates in the dataset by adding a small fraction
data_len = length(data);

% Initialize adjusted_data with the original data
data_fix = data;

% Sort the data to find duplicates easily
data_sort = sort(data_fix);

% Iterate over the sorted data to find and adjust duplicates
for idx = 2:data_len
    if data_sort(idx) == data_sort(idx-1)
        % Adjust the duplicate by adding a small fraction
        % The fraction here is 1e-10, but you can change it as needed
        data_sort(idx) = data_sort(idx) + eps;
    end
end

% Apply the adjustments back to the original data order
[~, originalOrder] = sort(data_fix);
data_fix(originalOrder) = data_sort;

end