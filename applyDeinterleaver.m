function deinterleaved = applyDeinterleaver(data, target_length, config)

block_size = config.block_size;
num_blocks = ceil(numel(data) / block_size);
required_length = num_blocks * block_size;
pad_len = required_length - numel(data);

data_padded = [data(:); zeros(pad_len, 1, 'uint8')];
deinterleaved = zeros(required_length, 1, 'uint8');

for i = 1:num_blocks
    a = (i-1)*block_size + 1;
    b = i*block_size;
    deinterleaved(a:b) = matdeintrlv(data_padded(a:b), ...
        config.interleaver_rows, config.interleaver_cols);
end

deinterleaved = deinterleaved(1:target_length);
end
