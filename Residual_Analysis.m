clear all;

%% setting parpmeter
FilePath = 'D:\NTSU\TenLab\ComputerMouse\motion\S1_90s_C_4-Mouse C.trc';
SamplingFrequency = 180;

%% load file
% loading data
opts = detectImportOptions(FilePath, 'FileType','text');
% preview(FilePath, opts)
RawData = readtable(FilePath, opts);
% parameter setting
TimeFrame = RawData(:, 2);
MotionData = RawData(:, 3:14); % 

%% Residual Analysis
% parameter setting
CutoffFrequency = 0.01:0.01:20;  % cut off frequency
F_MotionData = [];
R_diff = [];

for i = 1:size(CutoffFrequency, 2)
    % filter processing
    [A,B] = butter(2, CutoffFrequency(i)/(SamplingFrequency/2), 'low');
    F_MotionData.Variables = filtfilt(A, B, MotionData.Variables);
    % residual processing
    ps = size(F_MotionData.Variables);
    R_diff.Variables = ((MotionData.Variables - F_MotionData.Variables).^2);
    % calculate all of segments
    R(i, :) = sqrt(sum(R_diff.Variables(:, 4) + R_diff.Variables(:, 5) + R_diff.Variables(:, 6))./(ps(1)*3));
end

%% draw cutoff frequency
% setting linear equation
Slope = (R(end, 1)- R(end-500, 1))/500;
y = Slope*CutoffFrequency + (R(end, 1) - Slope*4);
yy = Slope*4 - R(end, 1);
[~, iMin] = min(abs(R-abs(yy)));


%% draw the figure
figure,
plot(CutoffFrequency, R(:, 1)), hold on
plot(CutoffFrequency, y), hold on
yline(-yy, '--', 'Cutofffrequency')
% text(iMin/100, -yy, '\rightarrow Cutoff frequency')

grid on
xlim([0 20])
ylabel('RMSE')
xlabel('Frequency (Hz)')
title(['Cutoff Frequency = ', num2str(iMin(1)*0.01), ' Hz'])
