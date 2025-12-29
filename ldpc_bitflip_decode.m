function c_hat = ldpc_bitflip_decode(c_init, H, degCol, maxIter)
%LDPC_BITFLIP_DECODE Decode an LDPC codeword using parallel bit-flipping.
% C_HAT = LDPC_BITFLIP_DECODE(C_INIT, H, DEGCOL, MAXITER) performs iterative
% hard-decision decoding.

c_hat = uint8(c_init(:));

for it = 1:maxIter
    % Tinh syndrome
    s_chk = mod(H * double(c_hat), 2);
    
    % Early stop neu syndrome = 0
    if ~any(s_chk)
        break;
    end
    
    % Dem so check vi pham
    cnt = full(H' * s_chk);
    
    % Flip bits
    flip = cnt > (degCol / 2);
    
    if ~any(flip)
        break;
    end
    
    % Lat bit
    c_hat(flip) = bitxor(c_hat(flip), 1, 'uint8');
end
end
