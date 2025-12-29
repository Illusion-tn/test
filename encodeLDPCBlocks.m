function [encoded, numBlocks] = encodeLDPCBlocks(data, data_length, config)
%ENCODELDPCBLOCKS Pad and LDPC-encode a bitstream by k_ldpc-bit blocks.
% [ENCODED, NUMBLOCKS] = ENCODELDPCBLOCKS(DATA, DATA_LENGTH, CONFIG) pads DATA
% with zeros to a multiple of CONFIG.k_ldpc, reshapes into blocks, and encodes
% each block using ldpcEncode and CONFIG.cfgLDPCenc.
%
% Outputs:
%   ENCODED   - LDPC code bits (uint8), length = NUMBLOCKS*n_ldpc
%   NUMBLOCKS - number of LDPC blocks encoded
%
% See also decodeLDPCHard, LDPC_576_384

pad_len = mod(config.k_ldpc - mod(data_length, config.k_ldpc), config.k_ldpc);
data_padded = [data(:); zeros(pad_len, 1, 'uint8')];
numBlocks = numel(data_padded) / config.k_ldpc;

data_mat = reshape(data_padded, config.k_ldpc, numBlocks);
data_mat = logical(data_mat);

% LDPC encoding - SEQUENTIAL (ldpcEncode is already optimized)
% Note: Cannot parallelize because config.cfgLDPCenc is not serializable
fprintf('  -> Dang ma hoa %d LDPC blocks...\n', numBlocks);
ldpc_encoded = ldpcEncode(data_mat, config.cfgLDPCenc);

encoded = uint8(ldpc_encoded(:));
end
