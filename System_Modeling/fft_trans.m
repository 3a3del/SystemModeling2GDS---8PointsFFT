function y = fft_trans(x_in,T)
    % Input: x_in - 1x8 complex vector
    % Output: y - 1x8 complex vector (FFT result)
    x_in = cast(x_in, 'like', T.x);
    
    % STAGE 1: Bit-reversal and first butterfly operations
    % Bit-reverse input ordering: [0,4,2,6,1,5,3,7]
    x_stage1_in = cast([x_in(1), x_in(5), x_in(3), x_in(7), ...
                        x_in(2), x_in(6), x_in(4), x_in(8)], 'like', T.x_stage1_in);
    
    % First stage butterflies (twiddle factor W^0 = 1)
    x_stage1_out = cast(complex(zeros(1, 8)), 'like', T.x_stage1_out);
    x_stage1_out(1) = cast(x_stage1_in(1) + x_stage1_in(2), 'like', T.x_stage1_out); % x0 + x4
    x_stage1_out(2) = cast(x_stage1_in(1) - x_stage1_in(2), 'like', T.x_stage1_out); % x0 - x4
    x_stage1_out(3) = cast(x_stage1_in(3) + x_stage1_in(4), 'like', T.x_stage1_out); % x2 + x6
    x_stage1_out(4) = cast(x_stage1_in(3) - x_stage1_in(4), 'like', T.x_stage1_out); % x2 - x6
    x_stage1_out(5) = cast(x_stage1_in(5) + x_stage1_in(6), 'like', T.x_stage1_out); % x1 + x5
    x_stage1_out(6) = cast(x_stage1_in(5) - x_stage1_in(6), 'like', T.x_stage1_out); % x1 - x5
    x_stage1_out(7) = cast(x_stage1_in(7) + x_stage1_in(8), 'like', T.x_stage1_out); % x3 + x7
    x_stage1_out(8) = cast(x_stage1_in(7) - x_stage1_in(8), 'like', T.x_stage1_out); % x3 - x7
    
    % STAGE 2: Apply twiddle factors W^0, W^2 = -j
    x_stage2_out = cast(complex(zeros(1, 8)), 'like', T.x_stage2_out);
    x_stage2_out(1) = cast(x_stage1_out(1) + x_stage1_out(3), 'like', T.x_stage2_out); % W^0 = 1
    x_stage2_out(2) = cast(x_stage1_out(2) + cast(x_stage1_out(4) * cast(-1j, 'like', T.x_stage2_out), 'like', T.x_stage2_out), 'like', T.x_stage2_out); % W^2 = -j
    x_stage2_out(3) = cast(x_stage1_out(1) - x_stage1_out(3), 'like', T.x_stage2_out); % W^0 = 1
    x_stage2_out(4) = cast(x_stage1_out(2) - cast(x_stage1_out(4) * cast(-1j, 'like', T.x_stage2_out), 'like', T.x_stage2_out), 'like', T.x_stage2_out); % W^2 = -j
    x_stage2_out(5) = cast(x_stage1_out(5) + x_stage1_out(7), 'like', T.x_stage2_out); % W^0 = 1
    x_stage2_out(6) = cast(x_stage1_out(6) + cast(x_stage1_out(8) * cast(-1j, 'like', T.x_stage2_out), 'like', T.x_stage2_out), 'like', T.x_stage2_out); % W^2 = -j
    x_stage2_out(7) = cast(x_stage1_out(5) - x_stage1_out(7), 'like', T.x_stage2_out); % W^0 = 1
    x_stage2_out(8) = cast(x_stage1_out(6) - cast(x_stage1_out(8) * cast(-1j, 'like', T.x_stage2_out), 'like', T.x_stage2_out), 'like', T.x_stage2_out); % W^2 = -j
    
    % Compute twiddle factors as doubles
    W1d = exp(-1j * 2 * pi * 1 / 8);
    W2d = exp(-1j * 2 * pi * 2 / 8);
    W3d = exp(-1j * 2 * pi * 3 / 8);
    
    % Then cast to fixed-point
    W1 = cast(W1d, 'like', T.W1);
    W2 = cast(W2d, 'like', T.W2);
    W3 = cast(W3d, 'like', T.W3);
    
    y = cast(complex(zeros(1, 8)), 'like', T.y);
    y(1) = cast(x_stage2_out(1) + x_stage2_out(5), 'like', T.y); % W^0 = 1
    y(2) = cast(x_stage2_out(2) + cast(x_stage2_out(6) * W1, 'like', T.y), 'like', T.y); % W^1
    y(3) = cast(x_stage2_out(3) + cast(x_stage2_out(7) * W2, 'like', T.y), 'like', T.y); % W^2 = -j
    y(4) = cast(x_stage2_out(4) + cast(x_stage2_out(8) * W3, 'like', T.y), 'like', T.y); % W^3
    y(5) = cast(x_stage2_out(1) - x_stage2_out(5), 'like', T.y); % W^0 = 1
    y(6) = cast(x_stage2_out(2) - cast(x_stage2_out(6) * W1, 'like', T.y), 'like', T.y); % W^1
    y(7) = cast(x_stage2_out(3) - cast(x_stage2_out(7) * W2, 'like', T.y), 'like', T.y); % W^2 = -j
    y(8) = cast(x_stage2_out(4) - cast(x_stage2_out(8) * W3, 'like', T.y), 'like', T.y); % W^3
end