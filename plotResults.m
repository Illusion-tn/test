function plotResults(SNR, BER_theoretical, BER_bch, BER_ldpc, BER_combined, config)
%PLOTRESULTS Plot and compare BER curves for different coding schemes.
%   PLOTRESULTS(SNR, BER_THEORETICAL, BER_BCH, BER_LDPC, BER_COMBINED, CONFIG)
%   draws a semilog-y plot of BER versus Eb/N0 (dB) for:
%     - Uncoded 16-QAM theoretical approximation
%     - BCH-only
%     - LDPC-only (hard)
%     - BCH + interleaver + LDPC (hard)
%
%   Notes:
%     - This function only plots; it does not save figures by default.
%
%   See also semilogy

figure('Position', [100 100 1200 800]);

% Ly thuyet
semilogy(SNR, BER_theoretical, 'k--', 'LineWidth', 2.5, ...
    'DisplayName', '16QAM ly thuyet (uncoded)');
hold on;

% BCH only
valid = @(x) ~isnan(x) & (x > 0);
if any(valid(BER_bch))
    semilogy(SNR(valid(BER_bch)), BER_bch(valid(BER_bch)), 'r-s', 'LineWidth', 1.8, 'MarkerSize', 6, 'DisplayName', sprintf('BCH (%d,%d)', config.n_bch, config.k_bch));
end

% LDPC hard
if any(valid(BER_ldpc))
    semilogy(SNR(valid(BER_ldpc)), BER_ldpc(valid(BER_ldpc)), 'b-o', 'LineWidth', 1.8, 'MarkerSize', 6, 'DisplayName', 'LDPC (576,384) (hard)');
end

% Combined
if any(valid(BER_combined))
    semilogy(SNR(valid(BER_combined)), BER_combined(valid(BER_combined)), 'g-^', 'LineWidth', 1.8, 'MarkerSize', 6, 'DisplayName', 'BCH + Interleaver + LDPC (hard)');
end

grid on;
xlabel('Eb/N0 (dB)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('BER', 'FontSize', 14, 'FontWeight', 'bold');
title('So sanh BER: BCH, LDPC (hard) va Combined', 'FontSize', 16, 'FontWeight', 'bold');
legend('Location', 'southwest', 'FontSize', 12);
ylim([1e-6 1]);
xlim([min(SNR) max(SNR)]);

fprintf('\nDo thi da luu: BER_Comparison_HardDecision.png\n');
end
