function [encoded, numBlocks] = encodeBCHBlocks(data, data_length, config)
%ENCODEBCHBLOCKS Pad and BCH-encode a bitstream by (k_bch)-bit blocks.
%   [ENCODED, NUMBLOCKS] = ENCODEBCHBLOCKS(DATA, DATA_LENGTH, CONFIG) pads DATA
%   with zeros to a multiple of CONFIG.k_bch, reshapes into blocks, and encodes
%   each block using CONFIG.bchEncoder (comm.BCHEncoder).
%
%   Inputs:
%     DATA        - input bits (uint8/logical)
%     DATA_LENGTH - number of valid bits from DATA to encode
%     CONFIG      - configuration struct from System()
%
%   Outputs:
%     ENCODED   - BCH code bits, column vector (uint8), length = NUMBLOCKS*n_bch
%     NUMBLOCKS - number of BCH blocks encoded
%
%   See also decodeBCHBlocks, BCH

pad_len = mod(config.k_bch - mod(data_length, config.k_bch), config.k_bch);
data_padded = [data(:); zeros(pad_len, 1, 'uint8')];
numBlocks = numel(data_padded) / config.k_bch;

data_mat = reshape(data_padded, config.k_bch, numBlocks);
bch_encoded = false(config.n_bch, numBlocks);

for i = 1:numBlocks
    bch_encoded(:,i) = logical(config.bchEncoder(data_mat(:,i)));
end

encoded = uint8(bch_encoded(:));
end
