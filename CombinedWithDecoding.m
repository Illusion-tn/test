function [BER, decoded_bits] = CombinedWithDecoding(data_bits, original_length, EbN0dB, config)

try
    % BCH Encoding
    [bch_encoded, numBlocks_bch] = encodeBCHBlocks(data_bits, original_length, config);
    
    % Block Interleaving
    interleaved = applyInterleaver(bch_encoded, config);
    
    % LDPC Encoding
    [ldpc_encoded, numBlocks_ldpc] = encodeLDPCBlocks(interleaved, length(interleaved), config);
    
    % 16QAM + AWGN (hard-decision)
    R_total = config.R_bch * config.R_ldpc;
    [rx_bits, ~] = transmit16QAM(ldpc_encoded, EbN0dB, R_total);
    
    % LDPC Decoding
    ldpc_decoded = decodeLDPCHard(rx_bits, numBlocks_ldpc, length(interleaved), config);
    
    % Block De-interleaving
    deinterleaved = applyDeinterleaver(ldpc_decoded, length(bch_encoded), config);
    
    % BCH Decoding
    decoded_bits = decodeBCHBlocks(deinterleaved, numBlocks_bch, original_length, config);
    
    % Tính BER
    BER = sum(decoded_bits ~= data_bits) / double(original_length);
    
catch ME
    warning('Lỗi: %s', ME.message);
    BER = NaN;
    decoded_bits = data_bits;
end

release(config.bchDecoder);

end
