function decoded = decodeLDPCHard(data, numBlocks, original_length, config)
% DECODELDPCHARD - Giai ma LDPC (hard) bang bit-flipping
%
% data: vector uint8 do dai = N * numBlocks

data_mat = reshape(uint8(data(:)), config.n_ldpc, numBlocks);
decoded_mat = zeros(config.n_ldpc, numBlocks, 'uint8');

if config.USE_PARALLEL
    parfor b = 1:numBlocks
        decoded_mat(:, b) = ldpc_bitflip_decode(data_mat(:, b), config.H, config.degCol, config.maxIterLDPC);
    end
else
    for b = 1:numBlocks
        decoded_mat(:, b) = ldpc_bitflip_decode(data_mat(:, b), config.H, config.degCol, config.maxIterLDPC);
    end
end

% Lay phan message bits theo MessageIndices (an toan hon so voi gia dinh systematic 1:K)
msgIdx = config.msgIdx;
decoded = decoded_mat(msgIdx, :);
decoded = decoded(:);
decoded = decoded(1:original_length);
end
