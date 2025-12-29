function BER = BCH(data_bits, original_length, EbN0dB, config)
% SIMULATEBCHONLY - Mo phong chi su dung BCH
fprintf('1) BCH (%d,%d)\n', config.n_bch, config.k_bch);

try
    % Padding va encoding
    [bch_encoded, numBlocks] = encodeBCHBlocks(data_bits, original_length, config);
    
    % BPSK + AWGN
    [rx_bits, ~] = transmitQPSK(bch_encoded, EbN0dB, config.R_bch);
    
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
