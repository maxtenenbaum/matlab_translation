function rank_arr = getMedianRank(data,method,getUnique)
if contains2(method,{'0.5','Haz'})
    method = 'hazen';
elseif contains2(method,{'0.3','0.4','Bern'})
    method = 'bernard';
elseif contains2(method,{'beta','inv'})
    method = 'inverse-beta';
end

data = sort(data);
if getUnique
    data = unique(data);
end

n = length(data);
idx_arr = transpose(1:n);
rank_arr = zeros(n,1);

for idx = 1:n
    switch lower(method)
        case 'hazen'
            rank_arr(idx) = (idx_arr(idx) - 0.5) / n;
        case 'bernard'
            rank_arr(idx) =(idx_arr(idx) - 0.3) / (n + 0.4);
        case 'inverse-beta'
            beta_a = idx;
            beta_b = n + 1 - idx;
            rank_arr(idx) = betainv(0.5,beta_a,beta_b);
    end
end

end