function decoded = decodeBCH(data, numBlocks, original_length, config)
% DECODEBCHBLOCKS - Giai ma BCH theo blocks

data_mat = reshape(data, config.n_bch, numBlocks);
dec_bch = false(config.k_bch, numBlocks);

for i = 1:numBlocks
    [dec_tmp, ~] = config.bchDecoder(data_mat(:,i));
    dec_bch(:,i) = logical(dec_tmp);
end

decoded = uint8(dec_bch(:));
decoded = decoded(1:original_length);
end
