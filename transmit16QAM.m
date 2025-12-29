function [rx_bits, rx_symbols, tx_symbols, pad_len] = transmit16QAM(tx_bits, EbN0dB, codeRate)
%TRANSMIT16QAM 16-QAM Gray modulation over AWGN with hard-decision demodulation.
% [RX_BITS, RX_SYMBOLS, TX_SYMBOLS, PAD_LEN] = TRANSMIT16QAM(TX_BITS, EBN0DB, CODERATE)
% maps TX_BITS to Gray-coded 16-QAM symbols (unit average power), adds AWGN,
% demodulates with hard decisions, and returns RX_BITS.
%
% Inputs:
%   TX_BITS  - bit vector (uint8/logical)
%   EBN0DB   - Eb/N0 in dB
%   CODERATE - overall code rate R (default 1)
%
% Outputs:
%   RX_BITS    - received bits after hard demod (uint8)
%   RX_SYMBOLS - received complex symbols
%   TX_SYMBOLS - transmitted complex symbols
%   PAD_LEN    - number of zero bits appended
%
% See also qammod, qamdemod, awgn

if nargin < 3 || isempty(codeRate)
    codeRate = 1;
end

% Handle empty input
if isempty(tx_bits)
    rx_bits = uint8([]);
    rx_symbols = [];
    tx_symbols = [];
    pad_len = 0;
    return;
end

% Ensure column vector of uint8
tx_bits = uint8(tx_bits(:));

M = 16;
k = 4; % bits per symbol

% Pad to multiple of k
pad_len = mod(k - mod(numel(tx_bits), k), k);
if pad_len ~= 0
    tx_bits = [tx_bits; zeros(pad_len, 1, 'uint8')];
end

% Modulation: qammod expects column vector when InputType='bit'
try
    tx_symbols = qammod(tx_bits, M, 'InputType', 'bit', 'UnitAveragePower', true);
catch ME
    % Fallback for older MATLAB versions
    Ns = numel(tx_bits) / k;
    bits_mat = reshape(tx_bits, k, Ns).';
    tx_symbols = qammod(bits_mat, M, 'gray', 'InputType', 'bit');
    tx_symbols = tx_symbols / sqrt(mean(abs(tx_symbols).^2));
end

% Eb/N0 -> Es/N0 conversion
EsN0dB = EbN0dB + 10*log10(k * double(codeRate));

% Add AWGN
rx_symbols = awgn(tx_symbols, EsN0dB, 'measured');

% Hard decision demodulation
try
    rx_bits = qamdemod(rx_symbols, M, 'OutputType', 'bit', 'UnitAveragePower', true);
catch ME
    rx_bits_mat = qamdemod(rx_symbols, M, 'gray', 'OutputType', 'bit');
    rx_bits = rx_bits_mat(:);
end

% Convert to uint8 and remove padding
rx_bits = uint8(rx_bits);
if pad_len ~= 0
    rx_bits = rx_bits(1:end-pad_len);
end

end
