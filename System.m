function config = System()
%SYSTEM Create a configuration struct for channel-coding simulations.
% CONFIG = SYSTEM() builds and returns a struct that contains:
% - BCH(255,239) encoder/decoder objects
% - QC-LDPC (576,384) parity-check matrix H (192x576) and encoder config
% - Block interleaver parameters
% - Simulation options (e.g., parallel decoding flag)
%
% This project targets a 16-QAM over AWGN link with hard-decision demodulation.
%
% Output:
%   CONFIG (struct) with commonly used fields:
%     .n_bch, .k_bch, .R_bch, .bchEncoder, .bchDecoder
%     .H, .cfgLDPCenc, .msgIdx, .n_ldpc, .k_ldpc, .R_ldpc
%     .interleaver_rows, .interleaver_cols, .block_size
%     .USE_PARALLEL
%
% See also Main, LDPC_576_384, transmit16QAM, BCH, LDPCHard, Combined

%% BCH parameters
config.n_bch = 255;
config.k_bch = 239;
config.R_bch = config.k_bch / config.n_bch;
config.bchEncoder = comm.BCHEncoder(config.n_bch, config.k_bch);
config.bchDecoder = comm.BCHDecoder(config.n_bch, config.k_bch);

%% Interleaver
config.interleaver_rows = 180;
config.interleaver_cols = 180;
config.block_size = config.interleaver_rows * config.interleaver_cols;

%% LDPC (576,384) => H: 192x576, R = 2/3
[config.H, config.cfgLDPCenc, config.msgIdx] = LDPC_576_384();
config.n_ldpc = size(config.H, 2);
config.k_ldpc = numel(config.msgIdx);
config.R_ldpc = config.k_ldpc / config.n_ldpc;
config.degCol = full(sum(config.H, 1))';

%% Parallel processing - Optimized for multi-core CPU
config.USE_PARALLEL = true;

if config.USE_PARALLEL
    poolObj = gcp('nocreate');
    if isempty(poolObj)
        try
            % For i5-13400: 10 cores, use 8 workers (leave 2 for OS)
            numWorkers = 8;
            parpool('local', numWorkers);
            fprintf('>>> Parallel pool khoi tao: %d workers\n', numWorkers);
        catch ME
            warning('>>> Khong the tao parallel pool: %s', ME.message);
            fprintf('>>> Chuyen sang che do tuan tu (sequential)\n');
            config.USE_PARALLEL = false;
        end
    else
        fprintf('>>> Su dung parallel pool da co: %d workers\n', poolObj.NumWorkers);
    end
end

%% Display info
fprintf('========== CAU HINH HE THONG ==========\n');
fprintf('BCH Code:    n=%d, k=%d, R=%.4f\n', config.n_bch, config.k_bch, config.R_bch);
fprintf('LDPC (576,384): n=%d, k=%d, R=%.4f\n', config.n_ldpc, config.k_ldpc, config.R_ldpc);
fprintf('Interleaver: %dx%d = %d bits\n', config.interleaver_rows, config.interleaver_cols, config.block_size);
fprintf('Parallel:    %s', mat2str(config.USE_PARALLEL));
if config.USE_PARALLEL
    fprintf(' (%d workers)\n', gcp('nocreate').NumWorkers);
else
    fprintf(' (sequential)\n');
end
fprintf('=======================================\n\n');
end
