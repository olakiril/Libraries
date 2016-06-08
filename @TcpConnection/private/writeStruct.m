function toReturn = writeStruct(tcp,outStruct)
% Write Matlab structure to the network connection.
% AE 2007-10-04

% number of parameters
fields = fieldnames(outStruct);
n = length(fields);
toReturn = fliplr(typecast(int32(n),'uint8'));

% send them individually
for i = 1:n
    
    % field name, element type & size
    curField = outStruct.(fields{i});
    elemType = getTypeConstant(tcp,class(curField));
    [dim2, dim1] = size(curField);
    
    % element data
    switch elemType
        case getTypeConstant(tcp,'double')
            data = flipud(reshape(typecast(curField(:),'uint8'),8,[]));
        case getTypeConstant(tcp,'string')
            data = uint8([]);
            for j = 1:dim1
                for k = 1:dim2
                    data = [data, ...
                            fliplr(typecast(int32(length(curField{j,k})), ...
                                            'uint8')), ...       % string length
                            uint8(curField{j,k})];               % string data
                end
            end
        case getTypeConstant(tcp,'int32')
            data = flipud(reshape(typecast(curField(:),'uint8'),4,[]));
        case getTypeConstant(tcp,'char')
            data = uint8(curField);
        case getTypeConstant(tcp,'logical')
            data = uint8(curField);
    end
    
    % flatten to string
    toReturn = [toReturn, ...
                fliplr(typecast(int32(length(fields{i})),'uint8')), ... length
                uint8(fields{i}), ...                               field name
                fliplr(typecast(int32(elemType),'uint8')), ...      element type
                fliplr(typecast(int32(dim1), 'uint8')), ...         size x
                fliplr(typecast(int32(dim2), 'uint8')), ...         size y
                data(:)']; %                                        field data
end
            
