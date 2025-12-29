%MAIN Run BER simulations for BCH, LDPC, and BCH+LDPC over a 16-QAM AWGN channel.
% This script:
% 1) Initializes the system configuration (BCH + QC-LDPC (576,384))
% 2) Loads an input file and converts it to a bitstream
% 3) Sweeps Eb/N0 values and measures BER for:
%    - BCH(255,239) only
%    - LDPC(576,384) only (hard bit-flip decoding)
%    - BCH + block interleaver + LDPC (hard)
% 4) Plots results against an uncoded 16-QAM theoretical BER approximation
%
% Usage:
%   Run directly from MATLAB:
%   >> Main
%
% See also System, loadDataFile, BCH, LDPCHard, Combined, plotResults

clear; clc; close all;

%% Khoi tao he thong
config = System();
config.maxIterLDPC = 30;
config.SNR = 0:0.5:11;

%% Doc du lieu
[data_bits, original_length] = loadDataFile('Imagine Dragons - Demons.mp4');

%% Khoi tao ket qua
BER_bch = zeros(1, numel(config.SNR));
BER_ldpc = zeros(1, numel(config.SNR));
BER_combined = zeros(1, numel(config.SNR));

%% Vong lap SNR
fprintf('\n========== BAT DAU MO PHONG ==========\n');
totalTic = tic;

for si = 1:numel(config.SNR)
    snrTic = tic;
    EbN0dB = config.SNR(si);
    fprintf('\n[%d/%d] Eb/N0 = %.1f dB\n', si, numel(config.SNR), EbN0dB);
    
    % 1. BCH only
    BER_bch(si) = BCH(data_bits, original_length, EbN0dB, config);
    
    % 2. LDPC only (hard-decision)
    BER_ldpc(si) = LDPCHard(data_bits, original_length, EbN0dB, config);
    
    % 3. BCH + Interleaver + LDPC
    BER_combined(si) = Combined(data_bits, original_length, EbN0dB, config);
    
    snrTime = toc(snrTic);
    fprintf('>>> Thoi gian SNR nay: %.1f giay (%.2f phut)\n', snrTime, snrTime/60);
    
    % Estimate remaining time
    avgTime = toc(totalTic) / si;
    remainingPoints = numel(config.SNR) - si;
    estimatedRemaining = avgTime * remainingPoints;
    fprintf('>>> Uoc tinh thoi gian con lai: %.1f phut\n', estimatedRemaining/60);
end

totalTime = toc(totalTic);
fprintf('\n>>> Tong thoi gian mo phong: %.1f phut (%.2f gio)\n', totalTime/60, totalTime/3600);

%% BER ly thuyet (16QAM, xap xi Gray-coded, uncoded)
EbN0 = 10.^(config.SNR/10);
BER_theoretical = (3/8) * erfc(sqrt(0.4 * EbN0));

%% Ve va luu ket qua
plotResults(config.SNR, BER_theoretical, BER_bch, BER_ldpc, BER_combined, config);

%% Cleanup parallel pool
if config.USE_PARALLEL
    delete(gcp('nocreate'));
    fprintf('\n>>> Parallel pool da dong.\n');
end

fprintf('\n========== HOAN TAT ==========\n');
