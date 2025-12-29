function decoded = decodeBCHBlocks(data, numBlocks, original_length, config)
% DECODEBCHBLOCKS - Compatibility wrapper (calls decodeBCH)
decoded = decodeBCH(data, numBlocks, original_length, config);
end
