function [H, cfgEnc, msgIdx] = LDPC_576_384()
%LDPC_576_384 Build a QC-LDPC parity-check matrix for (n,k) = (576,384), Z = 48.
% [H, CFGEnc, MSGIDX] = LDPC_576_384() constructs a 192x576 sparse logical
% parity-check matrix H from a 4x12 base matrix (circulant shifts). The parity
% part is chosen to be triangular with identity blocks to ensure ldpcEncoderConfig
% can derive a valid encoder configuration.
%
% Outputs:
%   H      - sparse logical parity-check matrix (192x576)
%   CFGEnc - ldpcEncoderConfig object for H
%   MSGIDX - indices of message bits within the LDPC codeword (column vector)
%
% See also ldpcEncoderConfig, ldpcEncode

Z = 48;
Mb = 4;  % 192/48
Nb = 12; % 576/48

% Base matrix Hb (Mb x Nb) with circulant shifts in [0, Z-1], and -1 for zero blocks.
Hb = -1 * ones(Mb, Nb);

% ---- Data part (first 8 block-columns => 384 bits) ----
Hb(1,1:8) = [ 0,  1,  2, -1,  5,  7, -1, 11];
Hb(2,1:8) = [ 1, -1,  0,  3,  6, -1,  9, 12];
Hb(3,1:8) = [-1,  2,  1,  4, -1,  8, 10, -1];
Hb(4,1:8) = [ 3,  0, -1,  1,  2,  4,  6,  8];

% ---- Parity part (last 4 block-columns => 192 parity bits) ----
Hb(1,  9) = 0;
Hb(2, 10) = 0;
Hb(3, 11) = 0;
Hb(4, 12) = 0;

% Extra connections (below diagonal) to improve decoding robustness
Hb(2, 9) = 1;
Hb(3, 10) = 1;
Hb(4, 11) = 1;
Hb(3, 9) = 2;
Hb(4, 10) = 2;
Hb(4, 9) = 3;

% Expand Hb into sparse logical H
M = Mb * Z;
N = Nb * Z;

% Pre-allocate indices for ones
nnz_est = nnz(Hb ~= -1) * Z;
rows = zeros(nnz_est, 1);
cols = zeros(nnz_est, 1);
idx = 1;

for rb = 0:Mb-1
    r0 = rb * Z;
    for cb = 0:Nb-1
        s = Hb(rb+1, cb+1);
        if s >= 0
            c0 = cb * Z;
            ii = (0:Z-1)';
            rows(idx:idx+Z-1) = r0 + ii + 1;
            cols(idx:idx+Z-1) = c0 + mod(ii + s, Z) + 1;
            idx = idx + Z;
        end
    end
end

rows = rows(1:idx-1);
cols = cols(1:idx-1);
H = sparse(rows, cols, true, M, N);

% Create encoder config
cfgEnc = ldpcEncoderConfig(H);

% FIX: For systematic LDPC codes, message bits are always at positions 1:K
msgIdx = (1:cfgEnc.NumInformationBits)';

% Verify dimensions
if cfgEnc.NumInformationBits ~= 384
    warning('LDPC_576_384:UnexpectedK', ...
        'Expected K=384, got K=%d', cfgEnc.NumInformationBits);
end

end
