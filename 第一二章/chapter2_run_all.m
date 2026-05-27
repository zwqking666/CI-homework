% 第二章智能优化基础实验报告配套程序
% 运行方式：
%   1. 在 MATLAB 中切换到“报告代码”目录；
%   2. 执行 chapter2_run_all。
%
% 程序会完成两项实验：
%   实验1：旅行商问题 TSP 穷举求解与运行时间分析；
%   实验2：读取 Results_A.mat 到 Results_D.mat，完成算法性能统计分析。

clear;
clc;
close all;

codeDir = fileparts(mfilename('fullpath'));
chapterDir = fileparts(codeDir);
outputDir = fullfile(chapterDir, '实验报告输出');
if exist(outputDir, 'dir') ~= 7
    mkdir(outputDir);
end

fprintf('===== 实验1：TSP穷举求解 =====\n');
task1Summary = run_tsp_experiment(outputDir);
disp(task1Summary);

fprintf('\n===== 实验2：智能优化算法性能分析 =====\n');
dataDir = fullfile(chapterDir, '实验2：智能优化算法性能分析', '实验数据结果');
[task2Summary, rankTestTable] = analyze_optimizer_results(dataDir, outputDir);
disp(task2Summary);
disp(rankTestTable);

fprintf('\n全部结果已保存到：%s\n', outputDir);

