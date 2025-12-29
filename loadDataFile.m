function [data_bits, data_length] = loadDataFile(filename)
%LOADDATAFILE Load a binary file and convert it into a bitstream (uint8).
%   [DATA_BITS, DATA_LENGTH] = LOADDATAFILE(FILENAME) reads raw bytes from
%   FILENAME and converts each byte to 8 bits (left-msb) to form DATA_BITS.
%
%   Outputs:
%     DATA_BITS   - column vector of bits (uint8), values 0/1
%     DATA_LENGTH - total number of bits in DATA_BITS
%
%   Example:
%     [bits, L] = loadDataFile('input.bin');
%
%   See also de2bi, fopen, fread

    fid = fopen(filename, 'rb');
    data = fread(fid, '*uint8');
    fclose(fid);
% Chuyen sang bit stream
data_bits = de2bi(data, 8, 'left-msb')';
data_bits = uint8(data_bits(:));
data_length = numel(data_bits);

fprintf('Du lieu goc: %d bits (%.2f KB)\n', data_length, data_length/8/1024);
end
