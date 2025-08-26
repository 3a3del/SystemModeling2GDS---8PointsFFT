function T = fft_trans_types(dt)
switch dt
    case 'double'
        T.x_real = double([]);
        T.x_imag = double([]);
        T.x = double([]);
        T.x_stage1_in = double([]);
        T.x_stage1_out = double([]);
        T.x_stage2_out = double([]);
        T.W1 = double([]);
        T.W2 = double([]);
        T.W3 = double([]);
        T.y = double([]);
    case 'single'
        T.x_real = single([]);
        T.x_imag = single([]);
        T.x = single([]);
        T.x_stage1_in = single([]);
        T.x_stage1_out = single([]);
        T.x_stage2_out = single([]);
        T.W1 = single([]);
        T.W2 = single([]);
        T.W3 = single([]);
        T.y = single([]);
    case 'FxPt'
        T.x_real = fi([], 1, 4 + 12, 12);
        T.x_imag = fi([], 1, 4 + 12, 12);
        T.x = fi([], 1, 4 + 12, 12);
        T.x_stage1_in = fi([], 1, 4 + 12, 12);
        T.x_stage1_out = fi([], 1, 4 + 12, 12);
        T.x_stage2_out = fi([], 1, 5 + 11, 11);
        T.W1 = fi([], 1, 1 + 15, 15);
        T.W2 = fi([], 1, 1 + 15, 15);
        T.W3 = fi([], 1, 1 + 15, 15);
        T.y = fi([], 1, 5 + 11, 11);   
end
end