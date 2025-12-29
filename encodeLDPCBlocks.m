function [encoded, numBlocks] = encodeLDPCBlocks(data, data_length, config)
% ENCODELDPCBLOCKS - Manual LDPC encoding (systematic code)

pad_len = mod(config.k_ldpc - mod(data_length, config.k_ldpc), config.k_ldpc);
data_padded = [data(:); zeros(pad_len, 1, 'uint8')];

numBlocks = numel(data_padded) / config.k_ldpc;
data_mat = reshape(data_padded, config.k_ldpc, numBlocks);

H = config.H;
K = config.k_ldpc;
N = config.n_ldpc;
M = config.m_ldpc;

encoded_mat = zeros(N, numBlocks, 'uint8');

% Manual systematic encoding
for b = 1:numBlocks
    msg = uint8(data_mat(:, b));
    
    % Codeword = [message | parity]
    cw = zeros(N, 1, 'uint8');
    cw(1:K) = msg;  % Systematic part
    
    % Tính parity bits: H * c = 0 (mod 2)
    % H = [H1 | H2] với H1: MxK, H2: MxM
    % H1 * msg + H2 * parity = 0
    % parity = H2^(-1) * H1 * msg (mod 2)
    
    H1 = H(:, 1:K);
    H2 = H(:, K+1:N);
    
    syndrome = mod(H1 * double(msg), 2);
    
    % Giải trong GF(2)
    % Vì H2 là khả nghịch (đã kiểm tra), dùng linear solve
    parity = gf_solve(H2, syndrome);
    
    cw(K+1:N) = uint8(parity);
    
    encoded_mat(:, b) = cw;
end

encoded = encoded_mat(:);

end

function x = gf_solve(A, b)
% Giải hệ phương trình Ax = b trong GF(2)
% A: sparse logical hoặc double
% b: vector

A_full = full(double(A));
b_full = double(b);

% Gaussian elimination trong GF(2)
[m, n] = size(A_full);
Ab = [A_full, b_full];  % Augmented matrix

for i = 1:min(m,n)
    % Tìm pivot
    pivot_row = find(Ab(i:end, i), 1) + i - 1;
    if isempty(pivot_row)
        continue;
    end
    
    % Swap rows
    if pivot_row ~= i
        Ab([i, pivot_row], :) = Ab([pivot_row, i], :);
    end
    
    % Eliminate
    for j = 1:m
        if j ~= i && Ab(j, i) == 1
            Ab(j, :) = mod(Ab(j, :) + Ab(i, :), 2);
        end
    end
end

% Back substitution
x = Ab(:, end);
x = x > 0.5;  % Convert to logical

end
