function buffer_mat = addToBuffer(buffer_mat,arr)

[bufferLength,~] = size(buffer_mat);
if all(buffer_mat)
    buffer_mat(1:bufferLength-1,:) = buffer_mat(2:bufferLength,:);
    buffer_mat(bufferLength,:) = arr;
else
    [r,~] = find(buffer_mat == 0,1);
    buffer_mat(r,:) = arr;
end

end