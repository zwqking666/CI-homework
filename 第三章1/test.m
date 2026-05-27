clc;clear;close all;
%% 测试GA算法，解决TSP旅行商问题
%算法参数输入
popsize = 100;
dimension=34;
maxiter = 1000;
disp('开始寻找最佳TSP城市路径序列...');
[gbestx,gbestfitness,gbesthistory]=GA_TSP(popsize,dimension,maxiter);

figure;
% 绘制GA算法收敛曲线
plot(gbesthistory,'r-');
title('GA-TSP 收敛曲线');
xlabel('迭代次数');
ylabel('适应度(最优路径长度)');
box on;
saveas(gcf,'tsp-curve','png');