function [choice] = getExpTypeCode(expType)
%% Constants
TYPE_IT = 'I-T';
TYPE_IV = 'I-V';
TYPE_CAP = 'CAP';
TYPE_STEP = 'STEP';

%% Variables
choice = '';

%% Function
if contains(expType,TYPE_IT,'IgnoreCase',true)
    choice = TYPE_IT;
elseif contains(expType,TYPE_IV,'IgnoreCase',true)
    choice = TYPE_IV;
elseif contains(expType,TYPE_CAP,'IgnoreCase',true)
    choice = TYPE_CAP;
elseif contains(expType,TYPE_STEP,'IgnoreCase',true)
    choice = TYPE_STEP;
end

end