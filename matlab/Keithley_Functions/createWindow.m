function fig_arr = createWindow(windowName,numOfTabs,nameList)
try
    delete(findall(groot,'Type','figure'));
catch
end
%% Function
fprintf('Initializing windows...');

% Instantiation
desktop = com.mathworks.mde.desk.MLDesktop.getInstance; %#ok<*JAPIMATHWORKS>

% Window
desktop.addGroup(windowName);
desktop.setGroupDocked(windowName,0);
windowDim = java.awt.Dimension(1,numOfTabs);
desktop.setDocumentArrangement(windowName,1,windowDim);
fig_arr = gobjects(numOfTabs,1);
for fig_idx = 1:numOfTabs
    if ~isempty(nameList)
        if iscell(nameList)
            name = nameList{fig_idx};
        else
            name = nameList(fig_idx);
        end
        fig_arr(fig_idx) = figure('Name',name,'NumberTitle','off','WindowStyle','docked');
    else
        fig_arr(fig_idx) = figure('Name',name,'NumberTitle','off','WindowStyle','docked');
    end
    fig = fig_arr(fig_idx);
    clf;
    set(get(handle(fig),'javaframe'),'GroupName',windowName); %#ok<*JAVFM> 
    set(fig_arr(fig_idx),'CloseRequestFcn','set(fig_obj,"Visible","off");');
end

fprintf('OK.\n\n');   % structure initialized

end