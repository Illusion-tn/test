function config = System()

% -------------------- BCH --------------------
config.n_bch = 255;
config.k_bch = 239;
config.R_bch = config.k_bch / config.n_bch;

config.bchEncoder = comm.BCHEncoder(config.n_bch, config.k_bch);
config.bchDecoder = comm.BCHDecoder(config.n_bch, config.k_bch);

% -------------------- LDPC (QC 576/384) --------------------
[H, cfgEnc] = LDPC_576_384(false);

config.H = H;
config.cfgLDPCenc = cfgEnc;

config.n_ldpc = size(H, 2);          % N = 576
config.m_ldpc = size(H, 1);          % M = 192
config.k_ldpc = config.n_ldpc - config.m_ldpc; % K ~ 384 (neu H full-rank)
config.R_ldpc = config.k_ldpc / config.n_ldpc; % 2/3

% Bit-flip decoder params
config.maxIterLDPC = 30;
config.degCol = full(sum(H, 1))';    % vector do bac cot (N x 1)

% -------------------- Interleaver --------------------
% Chon (rows x cols) = K_LDPC de dong bo block-size voi LDPC input
config.interleaver_rows = 24;
config.interleaver_cols = 16;
config.block_size = config.interleaver_rows * config.interleaver_cols;

if config.block_size ~= config.k_ldpc
    error('Interleaver block_size=%d phai bang k_ldpc=%d. Hay doi interleaver_rows/cols.', ...
        config.block_size, config.k_ldpc);
end

% -------------------- Parallel (tuy chon) --------------------
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

% -------------------- Display info --------------------
fprintf('========== CAU HINH HE THONG ==========\n');
fprintf('BCH Code:    n=%d, k=%d, R=%.4f\n', config.n_bch, config.k_bch, config.R_bch);
fprintf('LDPC QC:     n=%d, k=%d, R=%.4f\n', config.n_ldpc, config.k_ldpc, config.R_ldpc);
fprintf('Interleaver: %dx%d = %d bits\n', config.interleaver_rows, config.interleaver_cols, config.block_size);
fprintf('Parallel:    %s\n', mat2str(config.USE_PARALLEL));
fprintf('=======================================\n\n');

end
