function decoded = decodeBCHBlocks(data, numBlocks, original_length, config)
%DECODEBCHBLOCKS BCH-decode code bits by (n_bch)-bit blocks and truncate padding.
%   DECODED = DECODEBCHBLOCKS(DATA, NUMBLOCKS, ORIGINAL_LENGTH, CONFIG) reshapes
%   DATA into NUMBLOCKS BCH codewords, decodes using CONFIG.bchDecoder, then
%   returns the first ORIGINAL_LENGTH bits of the recovered bitstream.
%
%   Output:
%     DECODED - decoded bits (uint8), length = ORIGINAL_LENGTH
%
%   See also encodeBCHBlocks, BCH

data_mat = reshape(data, config.n_bch, numBlocks);
dec_bch = false(config.k_bch, numBlocks);

for i = 1:numBlocks
    [dec_bch(:,i), ~] = config.bchDecoder(data_mat(:,i));
end

decoded = uint8(dec_bch(:));
decoded = decoded(1:original_length);
end
