function removeFig(structFile)
%% Constants

%% Function
load(structFile); %#ok<LOAD>

varList = who;
structName = varList{FIRST};

try
    delete(findall(groot,'Type','figure'));
    save(structFile,structName);
catch
end

end