clear; clc; close all;
T= fft_trans_types('FxPt');
% DESIGN PARAMETERS
L = 50; % Number of test cases
N = 8; % FFT size
nSeeds = 50; % Number of random seeds
% Initialize arrays to store results
seed_errors = zeros(nSeeds, 1); % Maximum error for each seed
seed_mean_errors = zeros(nSeeds, 1); % Mean error for each seed
seed_status = zeros(nSeeds, 1); % 1 if passed, 0 if failed
seed_sqnr = zeros(nSeeds, 1); % SQNR for each seed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Running FFT error analysis for %d seeds...\n\n', nSeeds);

% Open files to write test cases and outputs from first seed
test_cases_file = fopen('seed1_test_cases.txt', 'w');
test_outputs_file = fopen('seed1_test_outputs.txt', 'w');

for seed = 1 : nSeeds
 rng(seed);
% TEST INPUTS - Generate random complex input
 x_real = cast(randn(L, N),'like',T.x_real);
 x_imag = cast(randn(L, N),'like',T.x_imag);
 x = cast(x_real + cast(1j * x_imag, 'like', T.x), 'like', T.x);

if seed == 1
 buildInstrumentedMex fft_trans -args {x(seed, :) , T}
 
 % Write test cases from first seed to file
 fprintf('Writing test cases from seed 1 to file...\n');
 for test_case = 1:L
     % Write each test case as a line with real and imaginary parts
     line_str = '';
     for n = 1:N
         if n == 1
             line_str = sprintf('%.6f+%.6fj', real(x(test_case, n)), imag(x(test_case, n)));
         else
             line_str = sprintf('%s, %.6f+%.6fj', line_str, real(x(test_case, n)), imag(x(test_case, n)));
         end
     end
     fprintf(test_cases_file, '%s\n', line_str);
 end
end

% 8-POINT RADIX-2 FFT ALGORITHM (3 stages)
% Initialize output arrays
 y = cast(zeros(L, N),'like',T.y);
for test_case = 1:L
% Apply our custom 8-point FFT function
 y(test_case, :) = fft_trans_mex(x(test_case, :),T);
end

% Write outputs from first seed to file
if seed == 1
    fprintf('Writing test outputs from seed 1 to file...\n');
    for test_case = 1:L
        % Write each output as a line with real and imaginary parts
        output_line_str = '';
        for n = 1:N
            if n == 1
                output_line_str = sprintf('%.6f+%.6fj', real(y(test_case, n)), imag(y(test_case, n)));
            else
                output_line_str = sprintf('%s, %.6f+%.6fj', output_line_str, real(y(test_case, n)), imag(y(test_case, n)));
            end
        end
        fprintf(test_outputs_file, '%s\n', output_line_str);
    end
end

% VERIFY RESULTS against MATLAB's built-in FFT
 test_errors = zeros(L, 1);
 test_passed = true;
 signal_power_total = 0;
 noise_power_total = 0;
for test_case = 1:L
 y_expected = fft(double(x(test_case, :)));
 error_vector = y(test_case, :) - y_expected;
 error_magnitude = abs(mean(error_vector));
 test_errors(test_case) = error_magnitude;
% Calculate signal and noise power for SQNR
% Use real() to ensure we get real power values
 signal_power = real(mean(abs(y_expected).^2));
 noise_power = real(mean(abs(error_vector).^2));
 signal_power_total = signal_power_total + signal_power;
 noise_power_total = noise_power_total + noise_power;
if error_magnitude > 1e-3
 fprintf('Seed %d: Test case %d failed with error: %.2e\n', seed, test_case, error_magnitude);
 test_passed = false;
break;
end
end
% Calculate SQNR for this seed
 avg_signal_power = real(signal_power_total / L);
 avg_noise_power = real(noise_power_total / L);
% Ensure we have real, positive values before taking log10
if avg_noise_power > 0 && avg_signal_power > 0
 sqnr_ratio = abs(avg_signal_power / avg_noise_power); % Use abs() to ensure positive real
if sqnr_ratio > 0 && isfinite(sqnr_ratio)
 seed_sqnr(seed) = 10 * log10(double(sqnr_ratio)); % Cast to double for safety
else
 seed_sqnr(seed) = -Inf; % Very poor reconstruction
end
elseif avg_noise_power <= eps && avg_signal_power > 0 % Use eps instead of exact 0
 seed_sqnr(seed) = Inf; % Perfect reconstruction
else
 seed_sqnr(seed) = -Inf; % Invalid or very poor case
end
% Store results for this seed
 seed_errors(seed) = max(test_errors);
 seed_mean_errors(seed) = mean(test_errors);
 seed_status(seed) = test_passed;
if test_passed
if isfinite(seed_sqnr(seed))
 fprintf('Seed %d: All %d test cases passed! Max error: %.2e, Mean error: %.2e, SQNR: %.1f dB\n', ...
 seed, L, seed_errors(seed), seed_mean_errors(seed), seed_sqnr(seed));
else
 fprintf('Seed %d: All %d test cases passed! Max error: %.2e, Mean error: %.2e, SQNR: Inf dB\n', ...
 seed, L, seed_errors(seed), seed_mean_errors(seed));
end
else
if isfinite(seed_sqnr(seed))
 fprintf('Seed %d: Failed! SQNR: %.1f dB\n', seed, seed_sqnr(seed));
else
 fprintf('Seed %d: Failed! SQNR: -Inf dB\n', seed);
end
end
end

% Close the files
fclose(test_cases_file);
fclose(test_outputs_file);
fprintf('\nTest cases from seed 1 have been saved to "seed1_test_cases.txt"\n');
fprintf('Test outputs from seed 1 have been saved to "seed1_test_outputs.txt"\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RESULTS SUMMARY  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n=== SUMMARY RESULTS ===\n');
passed_seeds = sum(seed_status);
failed_seeds = nSeeds - passed_seeds;

% Calculate average SQNR (excluding infinite values)
finite_sqnr = seed_sqnr(isfinite(seed_sqnr));
if ~isempty(finite_sqnr)
    avg_sqnr = mean(finite_sqnr);
    std_sqnr = std(finite_sqnr);
    min_sqnr = min(finite_sqnr);
    max_sqnr = max(finite_sqnr);
else
    avg_sqnr = NaN;
    std_sqnr = NaN;
    min_sqnr = NaN;
    max_sqnr = NaN;
end

fprintf('Seeds passed: %d/%d (%.1f%%)\n', passed_seeds, nSeeds, 100*passed_seeds/nSeeds);
fprintf('Seeds failed: %d/%d (%.1f%%)\n', failed_seeds, nSeeds, 100*failed_seeds/nSeeds);
fprintf('Overall maximum error: %.2e\n', max(seed_errors));
fprintf('Overall mean error: %.2e\n', mean(seed_mean_errors));
fprintf('Standard deviation of errors: %.2e\n', std(seed_mean_errors));
fprintf('\n=== SQNR ANALYSIS ===\n');
if ~isnan(avg_sqnr)
    fprintf('Average SQNR: %.2f dB\n', avg_sqnr);
    fprintf('SQNR Standard Deviation: %.2f dB\n', std_sqnr);
    fprintf('Minimum SQNR: %.2f dB\n', min_sqnr);
    fprintf('Maximum SQNR: %.2f dB\n', max_sqnr);
else
    fprintf('No finite SQNR values found\n');
end
fprintf('Seeds with infinite SQNR (perfect): %d\n', sum(isinf(seed_sqnr) & seed_sqnr > 0));
fprintf('Seeds with -infinite SQNR (failed): %d\n', sum(isinf(seed_sqnr) & seed_sqnr < 0));

% PLOTTING RESULTS
figure('Position', [100, 100, 1400, 900]);

% Plot 1: Error vs Seed Number (Linear Scale)
subplot(2, 3, 1);
plot(1:nSeeds, seed_errors, 'b-', 'LineWidth', 1.5, 'Marker', 'o', 'MarkerSize', 4);
hold on;
plot(1:nSeeds, seed_mean_errors, 'r--', 'LineWidth', 1.5, 'Marker', 's', 'MarkerSize', 4);
xlabel('Seed Number');
ylabel('Error Magnitude');
title('FFT Error Analysis by Seed (Linear Scale)');
legend('Maximum Error', 'Mean Error', 'Location', 'best');
grid on;
ylim([0, max(max(seed_errors), max(seed_mean_errors))]);

% Plot 2: Error vs Seed Number (Logarithmic Scale)
subplot(2, 3, 2);
valid_max_errors = seed_errors(seed_errors > 0);
valid_mean_errors = seed_mean_errors(seed_mean_errors > 0);
if ~isempty(valid_max_errors)
    semilogy(find(seed_errors > 0), valid_max_errors, 'b-', 'LineWidth', 1.5, 'Marker', 'o', 'MarkerSize', 4);
end
hold on;
if ~isempty(valid_mean_errors)
    semilogy(find(seed_mean_errors > 0), valid_mean_errors, 'r--', 'LineWidth', 1.5, 'Marker', 's', 'MarkerSize', 4);
end
xlabel('Seed Number');
ylabel('Error Magnitude (Log Scale)');
title('FFT Error Analysis by Seed (Log Scale)');
legend('Maximum Error', 'Mean Error', 'Location', 'best');
grid on;
if ~isempty(valid_max_errors) && ~isempty(valid_mean_errors)
    ylim([min(min(valid_max_errors), min(valid_mean_errors)), max(max(seed_errors), max(seed_mean_errors))]);
end

% Plot 3: SQNR vs Seed Number
subplot(2, 3, 3);
finite_indices = isfinite(seed_sqnr);
if sum(finite_indices) > 0
    plot(find(finite_indices), seed_sqnr(finite_indices), 'g-', 'LineWidth', 1.5, 'Marker', 'd', 'MarkerSize', 4);
    hold on;
end
if sum(seed_sqnr == Inf) > 0
    inf_indices = find(seed_sqnr == Inf);
    if sum(finite_indices) > 0
        plot(inf_indices, repmat(max(seed_sqnr(finite_indices)) + 10, length(inf_indices), 1), 'g^', 'MarkerSize', 8, 'MarkerFaceColor', 'green');
    else
        plot(inf_indices, repmat(100, length(inf_indices), 1), 'g^', 'MarkerSize', 8, 'MarkerFaceColor', 'green');
    end
end
xlabel('Seed Number');
ylabel('SQNR (dB)');
title('SQNR vs Seed Number');
grid on;
if sum(finite_indices) > 0
    ylim([min(seed_sqnr(finite_indices)) - 5, max(seed_sqnr(finite_indices)) + 15]);
end

% Plot 4: Histogram of Maximum Errors
subplot(2, 3, 4);
valid_errors = seed_errors(seed_errors > 0);
if ~isempty(valid_errors)
    histogram(log10(valid_errors), 20, 'FaceColor', 'blue', 'FaceAlpha', 0.7);
end
xlabel('Log10(Maximum Error)');
ylabel('Number of Seeds');
title('Distribution of Maximum Errors');
grid on;

% Plot 5: Histogram of SQNR
subplot(2, 3, 5);
if ~isempty(finite_sqnr)
    histogram(finite_sqnr, 20, 'FaceColor', 'green', 'FaceAlpha', 0.7);
end
xlabel('SQNR (dB)');
ylabel('Number of Seeds');
title('Distribution of SQNR');
grid on;

% Plot 6: Pass/Fail Status
subplot(2, 3, 6);
bar([passed_seeds, failed_seeds], 'FaceColor', [0.2, 0.6, 0.8]);
set(gca, 'XTickLabel', {'Passed', 'Failed'});
ylabel('Number of Seeds');
title('Pass/Fail Summary');
for i = 1:2
    if i == 1
        text(i, passed_seeds + 1, sprintf('%d\n(%.1f%%)', passed_seeds, 100*passed_seeds/nSeeds), ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    else
        text(i, failed_seeds + 1, sprintf('%d\n(%.1f%%)', failed_seeds, 100*failed_seeds/nSeeds), ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
end
grid on;

sgtitle('FFT Implementation Error Analysis with SQNR', 'FontSize', 14, 'FontWeight', 'bold');

% Additional figure for detailed error vs seed plot
figure('Position', [200, 200, 1000, 800]);

% Main error vs seed plot with enhanced visualization
subplot(2, 1, 1);
plot(1:nSeeds, seed_errors, 'b-', 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 6, 'MarkerFaceColor', 'blue');
hold on;
plot(1:nSeeds, seed_mean_errors, 'r--', 'LineWidth', 2, 'Marker', 's', 'MarkerSize', 6, 'MarkerFaceColor', 'red');

% Highlight failed seeds
failed_indices = find(seed_status == 0);
if ~isempty(failed_indices)
    plot(failed_indices, seed_errors(failed_indices), 'rx', 'MarkerSize', 12, 'LineWidth', 3, 'DisplayName', 'Failed Seeds');
    legend('Maximum Error', 'Mean Error', 'Failed Seeds', 'Location', 'best');
else
    legend('Maximum Error', 'Mean Error', 'Location', 'best');
end

xlabel('Seed Number');
ylabel('Error Magnitude');
title(sprintf('FFT Error vs Seed Number (%d seeds, %d test cases each)', nSeeds, L));
grid on;
xlim([1, nSeeds]);
ylim([0, max(max(seed_errors), max(seed_mean_errors))]);

% SQNR vs Seed plot
subplot(2, 1, 2);
finite_indices = isfinite(seed_sqnr);
if sum(finite_indices) > 0
    plot(find(finite_indices), seed_sqnr(finite_indices), 'g-', 'LineWidth', 2, 'Marker', 'd', 'MarkerSize', 6, 'MarkerFaceColor', 'green');
    hold on;
end
if sum(seed_sqnr == Inf) > 0
    inf_indices = find(seed_sqnr == Inf);
    if sum(finite_indices) > 0
        plot(inf_indices, repmat(max(seed_sqnr(finite_indices)) + 10, length(inf_indices), 1), 'g^', 'MarkerSize', 10, 'MarkerFaceColor', 'green', 'DisplayName', 'Perfect (Inf SQNR)');
    else
        plot(inf_indices, repmat(100, length(inf_indices), 1), 'g^', 'MarkerSize', 10, 'MarkerFaceColor', 'green', 'DisplayName', 'Perfect (Inf SQNR)');
    end
    legend('SQNR', 'Perfect (Inf SQNR)', 'Location', 'best');
elseif sum(finite_indices) > 0
    legend('SQNR', 'Location', 'best');
end
xlabel('Seed Number');
ylabel('SQNR (dB)');
title('SQNR vs Seed Number');
grid on;
xlim([1, nSeeds]);
if sum(finite_indices) > 0
    ylim([min(seed_sqnr(finite_indices)) - 5, max(seed_sqnr(finite_indices)) + 15]);
end

% DETAILED ERROR TABLE
fprintf('\n=== DETAILED ERROR TABLE ===\n');
fprintf('Seed\tStatus\t\tMax Error\tMean Error\tSQNR (dB)\n');
fprintf('----\t------\t\t---------\t----------\t---------\n');
for i = 1:min(50, nSeeds)
    status_str = {'FAILED', 'PASSED'};
    if isfinite(seed_sqnr(i))
        fprintf('%3d\t%s\t\t%.2e\t%.2e\t%8.2f\n', i, status_str{seed_status(i)+1}, seed_errors(i), seed_mean_errors(i), seed_sqnr(i));
    elseif seed_sqnr(i) == Inf
        fprintf('%3d\t%s\t\t%.2e\t%.2e\t%8s\n', i, status_str{seed_status(i)+1}, seed_errors(i), seed_mean_errors(i), 'Inf');
    else
        fprintf('%3d\t%s\t\t%.2e\t%.2e\t%8s\n', i, status_str{seed_status(i)+1}, seed_errors(i), seed_mean_errors(i), '-Inf');
    end
end

if nSeeds > 50
    fprintf('... (showing first 50 of %d seeds)\n', nSeeds);
end

% SAVE RESULTS TO FILE
results_table = table((1:nSeeds)', seed_status, seed_errors, seed_mean_errors, seed_sqnr, ...
    'VariableNames', {'Seed', 'Passed', 'MaxError', 'MeanError', 'SQNR_dB'});
writetable(results_table, 'fft_error_results.csv');
fprintf('\nResults saved to: fft_error_results.csv\n');
fprintf('\n=== FINAL SQNR SUMMARY ===\n');
if ~isnan(avg_sqnr)
    fprintf('Average SQNR across all seeds: %.2f dB\n', avg_sqnr);
else
    fprintf('No finite SQNR values to average\n');
end
%showInstrumentationResults fft_trans_mex -proposeFL -defaultDT numerictype(1, 32)