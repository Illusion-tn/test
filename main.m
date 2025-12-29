clear; clc; close all;

% Khoi tao he thong
config = system();

% SNR sweep (Eb/N0 dB)
config.SNR = 0:0.5:11;

% Doc du lieu (bitstream)
[data_bits, original_length] = loadDataFile('Imagine Dragons - Demons.mp4');

% Khoi tao ket qua
BER_bch = NaN(1, numel(config.SNR));
BER_ldpc = NaN(1, numel(config.SNR));
BER_combined = NaN(1, numel(config.SNR));

% Vong lap SNR
for si = 1:numel(config.SNR)
    EbN0dB = config.SNR(si);
    fprintf('\n===== Eb/N0 = %.1f dB (%d/%d) =====\n', EbN0dB, si, numel(config.SNR));

    % 1) BCH only
    BER_bch(si) = BCH(data_bits, original_length, EbN0dB, config);

    % 2) LDPC only (hard)
    BER_ldpc(si) = LDPCHard(data_bits, original_length, EbN0dB, config);

    % 3) BCH + Interleaver + LDPC
    BER_combined(si) = Combined(data_bits, original_length, EbN0dB, config);
end

% BER ly thuyet (uncoded) - chi de tham khao
BER_theoretical = 0.5 * erfc(sqrt(10.^(config.SNR/10)));

% Ve va luu ket qua
plotResults(config.SNR, BER_theoretical, BER_bch, BER_ldpc, BER_combined, config);
fprintf('\n========== HOAN TAT ==========\n');
