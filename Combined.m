function BER = Combined(data_bits, original_length, EbN0dB, config)

fprintf('3) BCH + Interleaver + LDPC (hard)\n');
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
    bch_decoded = decodeBCHBlocks(deinterleaved, numBlocks_bch, original_length, config);
    
    % Tinh BER
    BER = sum(bch_decoded ~= data_bits) / double(original_length);
    fprintf('BER(Comb) = %e\n', BER);
    
catch ME
    fprintf('Loi: %s\n', ME.message);
    BER = NaN;
end

release(config.bchDecoder);
end
