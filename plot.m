function plotResults(SNR, BER_theoretical, BER_bch, BER_ldpc, BER_combined, config)
% PLOTRESULTS - Ve do thi so sanh BER

figure('Position', [100 100 1200 800]);

valid = @(x) ~isnan(x) & (x > 0);

% Ly thuyet (uncoded)
semilogy(SNR, BER_theoretical, 'k--', 'LineWidth', 2.2, ...
    'DisplayName', 'Uncoded (theoretical)');
hold on;

% BCH
if any(valid(BER_bch))
    semilogy(SNR(valid(BER_bch)), BER_bch(valid(BER_bch)), 'r-s', ...
        'LineWidth', 1.8, 'MarkerSize', 6, ...
        'DisplayName', sprintf('BCH (%d,%d)', config.n_bch, config.k_bch));
end

% LDPC
if any(valid(BER_ldpc))
    semilogy(SNR(valid(BER_ldpc)), BER_ldpc(valid(BER_ldpc)), 'b-o', ...
        'LineWidth', 1.8, 'MarkerSize', 6, ...
        'DisplayName', sprintf('LDPC (%d,%d) hard', config.n_ldpc, config.k_ldpc));
end

% Combined
if any(valid(BER_combined))
    semilogy(SNR(valid(BER_combined)), BER_combined(valid(BER_combined)), 'm-^', ...
        'LineWidth', 1.8, 'MarkerSize', 6, ...
        'DisplayName', 'BCH + Interleaver + LDPC (hard)');
end

grid on;
xlabel('Eb/N0 (dB)');
ylabel('BER');
title('BER Comparison');
legend('Location', 'southwest');
ylim([1e-6 1]);
xlim([min(SNR) max(SNR)]);

saveas(gcf, 'BER_Comparison_HardDecision.png');
fprintf('\nDo thi da luu: BER_Comparison_HardDecision.png\n');
