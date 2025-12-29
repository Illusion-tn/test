function [H, cfgLDPCEnc] = build_LDPC_576_384(doPlot)
% BUILD_LDPC_576_384 - Xay dung ma tran QC-LDPC (576, 384)
%
% Output:
%   H         : Ma tran kiem tra (192 x 576) dang sparse
%   cfgLDPCEnc: Cau hinh cho ldpcEncode()
%
% Ghi chu:
%   - N = 576, K = 384, M = 192, R = 2/3, Z = 48
%   - H_base: -1 la zero-submatrix; so >=0 la do dich vong (shift)

if nargin < 1
    doPlot = false;
end

%% 1) Tham so
Z   = 48;   % expansion factor
M_b = 4;    % so hang base
N_b = 12;   % so cot base

%% 2) Base matrix (4 x 12)
H_base = [
    % 8 cot thong tin (Info)               | 4 cot parity (Parity)
     3  0 -1  2  0 -1  3  7                 1  0 -1 -1;
    -1  1  1  3 -1  3 -1  4                -1  0  0 -1;
     1 -1  7 -1  5  1  8 -1                -1 -1  0  0;
     0  4 -1  6 -1  4  1 -1                 0 -1 -1  0
];

%% 3) Expansion
M = M_b * Z;
N = N_b * Z;

H = sparse(M, N);
I = speye(Z);  % sparse identity

fprintf('Dang xay dung ma tran QC-LDPC (%d x %d), Z=%d ...\n', M, N, Z);

for r = 1:M_b
    row_start = (r-1)*Z + 1;
    row_end   = r*Z;
    for c = 1:N_b
        shift_val = H_base(r, c);
        if shift_val >= 0
            col_start = (c-1)*Z + 1;
            col_end   = c*Z;

            % circshift(I,[0,s]) => dich phai s cot (tren ma tran don vi)
            sub_mat = circshift(I, [0, shift_val]);
            H(row_start:row_end, col_start:col_end) = sub_mat;
        end
    end
end

%% 4) Tao encoder config
try
    cfgLDPCEnc = ldpcEncoderConfig(H);
    fprintf('>> H hop le cho ldpcEncode(). Code rate ~ %.4f\n', (N - M) / N);
catch ME
    warning('Khong tao duoc ldpcEncoderConfig. Kiem tra lai H_base / parity-part.');
    rethrow(ME);
end

%% 5) Plot (tuy chon)
if doPlot
    figure;
    spy(H);
    title(sprintf('QC-LDPC Parity-Check Matrix (%d x %d), Z=%d', M, N, Z));
    xlabel('Cot (bit)');
    ylabel('Hang (check)');
end

end
