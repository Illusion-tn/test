function BER = LDPCHard(data_bits, original_length, EbN0dB, config)
% SIMULATELDPCHARD - Mo phong LDPC voi hard-decision
fprintf('2) LDPC 1/2 (hard)\n');

try
    % Padding va encoding
    [ldpc_encoded, numBlocks] = encodeLDPCBlocks(data_bits, original_length, config);
    
    % 16QAM + AWGN
    [rx_bits, ~] = transmit16QAM(ldpc_encoded, EbN0dB, config.R_ldpc);
    
    % LDPC Decoding (parallel)
    decoded_bits = decodeLDPCHard(rx_bits, numBlocks, original_length, config);
    
    % Tinh BER
    BER = sum(decoded_bits ~= data_bits) / double(original_length);
    fprintf('   BER(LDPC) = %e\n', BER);
    
catch ME
    fprintf('   Loi: %s\n', ME.message);
    BER = NaN;
end
end
