function config = SystemConfig()
% SYSTEMCONFIG - Initialize simulation configuration

% -------------------- BCH --------------------
config.n_bch = 255;
config.k_bch = 239;
config.R_bch = config.k_bch / config.n_bch;

config.bchEncoder = comm.BCHEncoder(config.n_bch, config.k_bch);
config.bchDecoder = comm.BCHDecoder(config.n_bch, config.k_bch);

% -------------------- LDPC (QC 576/384) --------------------
[H, cfgEnc] = LDPC_576_384(false);

config.H = H;
config.cfgLDPCenc = cfgEnc;  % Struct chứa thông tin

config.n_ldpc = cfgEnc.BlockLength;          % 576
config.k_ldpc = cfgEnc.NumInformationBits;   % 384
config.m_ldpc = cfgEnc.NumParityBits;        % 192
config.msgIdx = cfgEnc.MessageIndices;
config.parityIdx = cfgEnc.ParityIndices;
config.R_ldpc = config.k_ldpc / config.n_ldpc;

% Bit-flip decoder params
config.maxIterLDPC = 30;
config.degCol = full(sum(config.H, 1))';

% -------------------- Interleaver --------------------
config.interleaver_rows = 24;
config.interleaver_cols = 16;
config.block_size = config.interleaver_rows * config.interleaver_cols;

if config.block_size ~= config.k_ldpc
    error('Interleaver block_size=%d must equal k_ldpc=%d', ...
        config.block_size, config.k_ldpc);
end

% -------------------- Parallel --------------------
config.USE_PARALLEL = false;
try
    if license('test', 'Distrib_Computing_Toolbox')
        config.USE_PARALLEL = true;
        if isempty(gcp('nocreate'))
            parpool('local', min(4, feature('numcores')));
        end
    end
catch
    config.USE_PARALLEL = false;
end

% -------------------- Display --------------------
fprintf('========== SYSTEM CONFIG =========\n');
fprintf('BCH:    n=%d, k=%d, R=%.6f\n', config.n_bch, config.k_bch, config.R_bch);
fprintf('LDPC:   n=%d, k=%d, R=%.6f\n', config.n_ldpc, config.k_ldpc, config.R_ldpc);
fprintf('Interleaver: %dx%d = %d bits\n', ...
    config.interleaver_rows, config.interleaver_cols, config.block_size);
fprintf('Parallel: %s\n', mat2str(config.USE_PARALLEL));
fprintf('==================================\n\n');

end
