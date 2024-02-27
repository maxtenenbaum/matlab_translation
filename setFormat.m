function File = setFormat(File,formatChoice)
%% Constants
MAX_NUM_OF_GPIB = 6;

%% Variables
gpib_arr = File.Instrument.Object;

%% Function
fprintf('Setting data format...');

switch upper(formatChoice)
    case {'ASCII','ASC','CHAR','STR','STRING','STRINGS'}
        type = 'ASCII';
        formatData = 'ASCii';
    case {'BIN','BINARY'}
        type = 'BIN';
%         formatData = 'REAL,32';
        formatData = 'SREal';
        gpib1 = gpib_arr(1);
        byteOrder = gpib1.ByteOrder;
        switch byteOrder
            case 'littleEndian'
                bytOrder = 'SWAPped';
            case 'bigEndian'
                bytOrder = 'NORMal';
        end
end

formatData_use = sprintf('FORMat:DATA %s',formatData);
for gpibNum = 1:MAX_NUM_OF_GPIB
    gpib = gpib_arr(gpibNum);
    fprintf(gpib,formatData_use);
    if contains2(type,'BIN')
        byOrder_use = sprintf('FORMat:BORDer %s',bytOrder);
        fprintf(gpib,byOrder_use);
    end
end
File.Instrument.Settings.Format = type;

fprintf('%s\n',type);

end