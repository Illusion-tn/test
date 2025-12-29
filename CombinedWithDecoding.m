function [BER, decoded_bits] = CombinedWithDecoding(data_bits, original_length, EbN0dB, config)

try
    [bch_encoded, numBlocks_bch] = encodeBCHBlocks(data_bits, original_length, config);
    interleaved = applyInterleaver(bch_encoded, config);

    [ldpc_encoded, numBlocks_ldpc] = encodeLDPCBlocks(interleaved, numel(interleaved), config);

    R_total = config.R_bch * config.R_ldpc;
    rx_bits = transmitQPSK(ldpc_encoded, EbN0dB, R_total);

    ldpc_decoded = decodeLDPCHard(rx_bits, numBlocks_ldpc, numel(interleaved), config);
    deinterleaved = applyDeinterleaver(ldpc_decoded, numel(bch_encoded), config);

    decoded_bits = decodeBCHBlocks(deinterleaved, numBlocks_bch, original_length, config);
    BER = sum(decoded_bits ~= data_bits) / double(original_length);

catch ME
    warning('Loi: %s', ME.message);
    BER = NaN;
    decoded_bits = data_bits;
end

release(config.bchDecoder);
end
