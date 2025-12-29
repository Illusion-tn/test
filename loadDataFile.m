function [data_bits, data_length] = loadDataFile(filename)
    fid = fopen(filename, 'rb');
    data = fread(fid, '*uint8');
    fclose(fid);
% Chuyen sang bit stream
data_bits = de2bi(data, 8, 'left-msb')';
data_bits = uint8(data_bits(:));
data_length = numel(data_bits);

fprintf('Du lieu goc: %d bits (%.2f KB)\n', data_length, data_length/8/1024);
end
