function BER = Combined(data_bits, original_length, EbN0dB, config)
% COMBINED - BCH + Interleaver + LDPC (hard) + QPSK/AWGN

fprintf('3) BCH + Interleaver + LDPC (hard)\n');

try
    % 1) BCH encode
    [bch_encoded, numBlocks_bch] = encodeBCHBlocks(data_bits, original_length, config);

    % 2) Interleave (block)
    interleaved = applyInterleaver(bch_encoded, config);

    % 3) LDPC encode
    [ldpc_encoded, numBlocks_ldpc] = encodeLDPCBlocks(interleaved, numel(interleaved), config);

    % 4) QPSK + AWGN
    R_total = config.R_bch * config.R_ldpc;
    rx_bits = transmitQPSK(ldpc_encoded, EbN0dB, R_total);

    % 5) LDPC decode (hard)
    ldpc_decoded = decodeLDPCHard(rx_bits, numBlocks_ldpc, numel(interleaved), config);

    % 6) Deinterleave
    deinterleaved = applyDeinterleaver(ldpc_decoded, numel(bch_encoded), config);

    % 7) BCH decode
    bch_decoded = decodeBCHBlocks(deinterleaved, numBlocks_bch, original_length, config);

    % 8) BER
    BER = sum(bch_decoded ~= data_bits) / double(original_length);
    fprintf('   BER(Comb) = %e\n', BER);

catch ME
    fprintf('   Loi: %s\n', ME.message);
    BER = NaN;
end

release(config.bchDecoder);
end
