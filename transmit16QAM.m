function [rx_bits, tx_symbols, rx_symbols, pad_len] = transmit16QAM(tx_bits, EsN0_dB)
% transmit16QAM - 16-QAM (Gray), Unit average symbol power, AWGN channel
%
% Input:
%   tx_bits : column vector (0/1 or logical). Length ideally multiple of 4.
%   EsN0_dB : Es/N0 in dB (symbol energy to noise density)
%
% Output:
%   rx_bits    : demodulated bits (same length as original tx_bits)
%   tx_symbols : transmitted complex 16-QAM symbols (unit average power)
%   rx_symbols : received symbols after AWGN
%   pad_len    : number of padded zeros added (0..3)

    M = 16;
    k = log2(M); % 4 bits/symbol
    tx_bits = tx_bits(:);

    % Pad to multiple of 4 bits
    remBits = mod(numel(tx_bits), k);
    if remBits ~= 0
        pad_len = k - remBits;
        tx_bits_p = [tx_bits; zeros(pad_len, 1, 'like', tx_bits)];
    else
        pad_len = 0;
        tx_bits_p = tx_bits;
    end

    % ----- MODULATE -----
    if exist('qammod','file') == 2
        % Communications Toolbox path
        tx_symbols = qammod(double(tx_bits_p), M, ...
            'InputType','bit', 'UnitAveragePower', true);
    else
        % Manual Gray 16-QAM mapping (I bits = b1b2, Q bits = b3b4)
        bits = reshape(double(tx_bits_p), k, []).'; % [nSym x 4]
        b1 = bits(:,1); b2 = bits(:,2);
        b3 = bits(:,3); b4 = bits(:,4);

        % Gray mapping for 2 bits -> levels: 00->-3, 01->-1, 11->+1, 10->+3
        map = [-3, -1, 3, 1]; % index by (b1*2+b2)+1 with binary codes 00,01,10,11
        I = map((b1*2 + b2) + 1);
        Q = map((b3*2 + b4) + 1);

        % Normalize to unit average symbol power (E{|s|^2}=1), factor sqrt(10)
        tx_symbols = (I + 1i*Q) / sqrt(10);
    end

    % ----- AWGN CHANNEL (Es/N0) -----
    EsN0 = 10.^(EsN0_dB/10);
    % Unit average symbol power => Es = 1, N0 = 1/EsN0
    % Per-dimension variance = N0/2 = 1/(2*EsN0)
    sigma2 = 1./(2*EsN0);
    noise = sqrt(sigma2) .* (randn(size(tx_symbols)) + 1i*randn(size(tx_symbols)));
    rx_symbols = tx_symbols + noise;

    % ----- DEMODULATE -----
    if exist('qamdemod','file') == 2
        rx_bits_p = qamdemod(rx_symbols, M, ...
            'OutputType','bit', 'UnitAveragePower', true);
        rx_bits_p = uint8(rx_bits_p(:));
    else
        % Manual hard-decision demap (nearest level on I/Q)
        y = rx_symbols * sqrt(10); % de-normalize back to I/Q levels
        I = real(y);
        Q = imag(y);

        levels = [-3 -1 1 3];

        Iq = nearest_level(I, levels);
        Qq = nearest_level(Q, levels);

        % inverse Gray mapping: -3->[0 0], -1->[0 1],  1->[1 1],  3->[1 0]
        [b1b2] = inv_gray_2bit(Iq);
        [b3b4] = inv_gray_2bit(Qq);

        bits = [b1b2 b3b4];                  % [nSym x 4]
        rx_bits_p = uint8(bits.');           % [4 x nSym]
        rx_bits_p = rx_bits_p(:);            % column
    end

    % Remove padding to match original length
    rx_bits = rx_bits_p(1:numel(tx_bits));
end

function q = nearest_level(x, levels)
    % x: vector, levels: 1x4
    x = x(:);
    d = abs(x - levels(1));
    q = levels(1) * ones(size(x));
    for i = 2:numel(levels)
        di = abs(x - levels(i));
        take = di < d;
        q(take) = levels(i);
        d(take) = di(take);
    end
end

function b = inv_gray_2bit(levels_quant)
    % levels_quant is column vector of quantized levels in {-3,-1,1,3}
    % return b as [n x 2]
    n = numel(levels_quant);
    b = zeros(n,2,'uint8');
    for i = 1:n
        v = levels_quant(i);
        if v == -3
            b(i,:) = [0 0];
        elseif v == -1
            b(i,:) = [0 1];
        elseif v == 1
            b(i,:) = [1 1];
        else % v == 3
            b(i,:) = [1 0];
        end
    end
end
