function c_hat = ldpc_bitflip_decode(c_init, H, degCol, maxIter)
% LDPC_BITFLIP_DECODE - Parallel Bit-Flipping Algorithm (hard-decision)
%
% Inputs:
%   c_init : (N x 1) uint8/logic - codeword nhan (hard bits)
%   H      : (M x N) sparse parity-check matrix
%   degCol : scalar hoac vector (N x 1) - bac cot
%   maxIter: so vong lap toi da

c_hat = uint8(c_init(:));

% Cho phep degCol la scalar hoac vector
if isscalar(degCol)
    degColVec = double(degCol) * ones(size(c_hat));
else
    degColVec = double(degCol(:));
    if numel(degColVec) ~= numel(c_hat)
        error('degCol phai la scalar hoac vector do dai N.');
    end
end

for it = 1:maxIter
    % Syndrome: s = H*c mod2
    s_chk = mod(H * double(c_hat), 2);

    % Neu syndrome = 0 => hop le
    if ~any(s_chk)
        break;
    end

    % Dem so check bi vi pham cho moi bit: cnt = H' * s
    cnt = full(H' * s_chk);  % (N x 1)

    % Lat bit neu so vi pham > degCol/2
    flip = cnt > (degColVec / 2);

    if ~any(flip)
        break;
    end

    c_hat(flip) = bitxor(c_hat(flip), uint8(1));
end
end
