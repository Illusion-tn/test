function decoded = decodeLDPCHard(data, numBlocks, original_length, config)
%DECODELDPCHARD Hard-decision LDPC decode using a bit-flipping algorithm.
% DECODED = DECODELDPCHARD(DATA, NUMBLOCKS, ORIGINAL_LENGTH, CONFIG) decodes
% NUMBLOCKS LDPC codewords from DATA (length NUMBLOCKS*n_ldpc). Each codeword
% is decoded using ldpc_bitflip_decode() with CONFIG.H and CONFIG.maxIterLDPC.
% The output is then extracted using CONFIG.msgIdx (MessageIndices) and
% truncated to ORIGINAL_LENGTH.
%
% Notes:
%   - If CONFIG.USE_PARALLEL is true, a PARFOR loop is used.
%
% See also ldpc_bitflip_decode, encodeLDPCBlocks

data_mat = reshape(data, config.n_ldpc, numBlocks);
decoded_mat = zeros(config.n_ldpc, numBlocks, 'uint8');

% Extract variables from config BEFORE parfor to avoid serialization issues
H_local = config.H;
degCol_local = config.degCol;
maxIter_local = config.maxIterLDPC;

if config.USE_PARALLEL
    fprintf('  -> Dang giai ma %d LDPC blocks (parallel)...\n', numBlocks);
    parfor b = 1:numBlocks
        decoded_mat(:,b) = ldpc_bitflip_decode(data_mat(:,b), ...
            H_local, degCol_local, maxIter_local);
    end
else
    fprintf('  -> Dang giai ma %d LDPC blocks (sequential)...\n', numBlocks);
    for b = 1:numBlocks
        decoded_mat(:,b) = ldpc_bitflip_decode(data_mat(:,b), ...
            H_local, degCol_local, maxIter_local);
    end
end

% Lay bit thong tin theo MessageIndices cua LDPC encoder
decoded = uint8(decoded_mat(config.msgIdx, :));
decoded = decoded(:);
decoded = decoded(1:original_length);
end
