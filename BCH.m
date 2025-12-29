function BER = BCH(data_bits, original_length, EbN0dB, config)

fprintf('1) BCH (%d,%d)\n', config.n_bch, config.k_bch);

try
    % Padding va encoding
    [bch_encoded, numBlocks] = encodeBCHBlocks(data_bits, original_length, config);
    
    % 16QAM + AWGN (hard-decision)
    [rx_bits, ~] = transmit16QAM(bch_encoded, EbN0dB, config.R_bch);
    
    % BCH Decoding
    decoded_bits = decodeBCHBlocks(rx_bits, numBlocks, original_length, config);
    
    % Tinh BER
    BER = sum(decoded_bits ~= data_bits) / double(original_length);
    fprintf('   BER(BCH)  = %e\n', BER);
    
catch ME
    fprintf('   Loi: %s\n', ME.message);
    BER = NaN;
end

release(config.bchDecoder);
end
