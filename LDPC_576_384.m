function [H, cfgLDPCEnc] = LDPC_576_384(doPlot)
% LDPC_576_384 - Xay dung ma tran QC-LDPC (576, 384)

if nargin < 1
    doPlot = false;
end

%% 1) Tham so
Z   = 48;
M_b = 4;
N_b = 12;

%% 2) Base matrix với dual-diagonal parity
H_base = [
     3  0  2  5  1  4  7  6    0 -1 -1 -1;
     1  4  6  3  0  7  2  5   -1  0 -1 -1;
     2  5  1  7  4  0  3  6   -1 -1  0 -1;
     7  3  4  1  6  5  0  2   -1 -1 -1  0;
];

%% 3) Expansion
M = M_b * Z;  % 192
N = N_b * Z;  % 576

H = zeros(M, N);

fprintf('Dang xay dung ma tran QC-LDPC (%d x %d), Z=%d ...\n', M, N, Z);

for r = 1:M_b
    row_start = (r-1)*Z + 1;
    row_end   = r*Z;
    for c = 1:N_b
        shift_val = H_base(r, c);
        if shift_val >= 0
            col_start = (c-1)*Z + 1;
            col_end   = c*Z;
            
            I = eye(Z);
            sub_mat = circshift(I, [0, shift_val]);
            H(row_start:row_end, col_start:col_end) = sub_mat;
        end
    end
end

H = sparse(logical(H));

fprintf('Ma tran H: %d x %d, density = %.4f\n', size(H,1), size(H,2), nnz(H)/numel(H));

%% 4) Kiểm tra parity part
K = N - M;  % 384
H_parity = full(H(:, K+1:end));
rank_parity = gfrank(H_parity, 2);

fprintf('Kiem tra parity part: rank = %d (can = %d)\n', rank_parity, M);

if rank_parity < M
    warning('Parity part khong full rank! Thay bang Identity...');
    H(:, K+1:end) = sparse(logical(speye(M)));
end

%% 5) Tạo config - CHỈ LƯU H, KHÔNG TẠO ldpcEncoderConfig
% Vì MessageIndices không hoạt động, ta tạo struct đơn giản
cfgLDPCEnc = struct();
cfgLDPCEnc.ParityCheckMatrix = H;
cfgLDPCEnc.MessageIndices = (1:K)';
cfgLDPCEnc.ParityIndices = (K+1:N)';
cfgLDPCEnc.NumInformationBits = K;
cfgLDPCEnc.NumParityBits = M;
cfgLDPCEnc.BlockLength = N;

fprintf('>> Tao struct config thanh cong: K=%d, N=%d, Rate=%.4f\n', K, N, K/N);

%% 6) Plot
if doPlot
    figure('Position', [100 100 1000 600]);
    spy(H);
    title(sprintf('QC-LDPC H (%d x %d)', M, N));
    grid on;
end

end
