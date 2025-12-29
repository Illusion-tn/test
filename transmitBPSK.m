function [rx_bits, sigma2] = transmitBPSK(bits, EbN0dB, codeRate)
%TRANSMITBPSK (Optional) BPSK over AWGN with hard decision demodulation.
%   [RX_BITS, SIGMA2] = TRANSMITBPSK(BITS, EBN0DB, CODERATE) is a lightweight
%   helper for BPSK/AWGN. It is NOT used by the current 16-QAM simulation chain,
%   but is kept as a reference utility.
%
%   Inputs:
%     BITS     - bit vector (uint8/logical)
%     EBN0DB   - Eb/N0 in dB
%     CODERATE - overall code rate (default 1)
%
%   Outputs:
%     RX_BITS - received hard bits (uint8)
%     SIGMA2  - noise variance per real dimension
%
%   See also transmit16QAM

if nargin < 3 || isempty(codeRate)
    codeRate = 1;
end

if isempty(bits)
    rx_bits = uint8([]);
    sigma2 = 0;
    return;
end

bits = uint8(bits(:));
% BPSK: 0 -> +1, 1 -> -1
tx = 1 - 2*double(bits);

% Eb/N0 -> Es/N0 for BPSK (k=1)
EsN0dB = EbN0dB + 10*log10(double(codeRate));
EsN0 = 10.^(EsN0dB/10);
sigma2 = 1./(2*EsN0);

noise = sqrt(sigma2) .* randn(size(tx));
rx = tx + noise;

rx_bits = uint8(rx < 0);
end
