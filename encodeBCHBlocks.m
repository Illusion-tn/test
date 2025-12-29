function [encoded, numBlocks] = encodeBCHBlocks(data, data_length, config)
% ENCODEBCHBLOCKS - Compatibility wrapper (calls encodeBCH)
[encoded, numBlocks] = encodeBCH(data, data_length, config);
end
