function [encoded, numBlocks] = encodeLDPCBlocks(data, data_length, config)
% ENCODELDPCBLOCKS - Ma hoa LDPC theo blocks (K = config.k_ldpc)

pad_len = mod(config.k_ldpc - mod(data_length, config.k_ldpc), config.k_ldpc);
data_padded = [data(:); zeros(pad_len, 1, 'uint8')];
numBlocks = numel(data_padded) / config.k_ldpc;

data_mat = reshape(data_padded, config.k_ldpc, numBlocks);
data_mat = logical(data_mat);

ldpc_encoded = ldpcEncode(data_mat, config.cfgLDPCenc); % (N x numBlocks) logical
encoded = uint8(ldpc_encoded(:));
end
