function BER = LDPCHard(data_bits, original_length, EbN0dB, config)
%LDPCHARD Simulate LDPC(576,384) channel coding over 16-QAM AWGN (hard decision).
%   BER = LDPCHARD(DATA_BITS, ORIGINAL_LENGTH, EBN0DB, CONFIG) encodes DATA_BITS
%   by blocks of k_ldpc bits, transmits with 16-QAM over AWGN, performs hard
%   bit-flip LDPC decoding, and returns BER.
%
%   Inputs/Outputs are the same pattern as BCH.m.
%
%   Notes:
%     - Hard-decision decoding is fast but usually has worse BER than soft LLR
%       decoding. This implementation is optimized for simplicity and speed.
%
%   See also encodeLDPCBlocks, decodeLDPCHard, ldpc_bitflip_decode, transmit16QAM

fprintf('2) LDPC (576,384) (hard)\n');

try
    % Padding va encoding
    [ldpc_encoded, numBlocks] = encodeLDPCBlocks(data_bits, original_length, config);
    
    % 16QAM + AWGN (hard-decision)
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
