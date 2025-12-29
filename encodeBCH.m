function [encoded, numBlocks] = encodeBCH(data, data_length, config)
% ENCODEBCHBLOCKS - Ma hoa BCH theo blocks

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
