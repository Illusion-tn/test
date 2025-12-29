function [rx_bits, rx_symbols, tx_symbols, pad_len] = transmit16QAM(tx_bits, EbN0_dB, codeRate)
% TRANSMIT16QAM - Điều chế 16-QAM (Gray) + kênh AWGN
% Inputs:
%   tx_bits  : Bit đầu vào (0/1)
%   EbN0_dB  : Eb/N0 (Energy per Bit / Noise Power Spectral Density)
%   codeRate : Tỷ lệ mã tổng (R_bch * R_ldpc). Mặc định = 1.

    if nargin < 3 || isempty(codeRate)
        codeRate = 1;
    end

    M = 16;
    k = 4; % bits per symbol
    
    % --- 1. PADDING & MAPPING ---
    tx_bits = uint8(tx_bits(:));
    num_bits = numel(tx_bits);
    
    % Pad để chia hết cho 4 (16-QAM)
    pad_len = mod(k - mod(num_bits, k), k);
    if pad_len == k, pad_len = 0; end
    
    tx_bits_padded = [tx_bits; zeros(pad_len, 1, 'uint8')];
    
    % Dùng hàm chuẩn của Matlab (nhanh và chính xác hơn thủ công)
    % InputType='bit', UnitAveragePower=true (Es=1)
    tx_symbols = qammod(tx_bits_padded, M, 'InputType', 'bit', ...
        'UnitAveragePower', true, 'PlotConstellation', false);

    % --- 2. TÍNH TOÁN NHIỄU (CRITICAL) ---
    % Công thức: Es/N0 = (Eb/N0) + 10*log10(k * R)
    EsN0_dB = EbN0_dB + 10*log10(k * codeRate);
    
    % Chuyển sang tuyến tính: Es/N0 = 10^(EsN0_dB/10)
    EsN0_lin = 10.^(EsN0_dB / 10);
    
    % Vì UnitAveragePower=true => Es = 1.
    % N0 = Es / EsN0_lin = 1 / EsN0_lin
    % Phương sai nhiễu (Noise Variance) cho mỗi chiều (I và Q):
    % sigma^2 = N0 / 2
    noiseVar = 1 ./ (2 * EsN0_lin);
    
    % Tạo nhiễu phức
    noise = sqrt(noiseVar) .* (randn(size(tx_symbols)) + 1i*randn(size(tx_symbols)));
    
    % Tín hiệu thu
    rx_symbols = tx_symbols + noise;

    % --- 3. DEMODULATION (HARD DECISION) ---
    % 'OutputType'='bit' trả về bit 0/1
    rx_bits_padded = qamdemod(rx_symbols, M, 'OutputType', 'bit', ...
        'UnitAveragePower', true);
    
    % Cắt bỏ padding
    rx_bits = rx_bits_padded(1:num_bits);
    rx_bits = uint8(rx_bits);
end