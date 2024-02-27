function tline = fgetl2(fid)

tline = fgetl(fid);
if ischar(tline)
    tline = erase(tline,newline);
end

end
