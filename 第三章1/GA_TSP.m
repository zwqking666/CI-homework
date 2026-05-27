function [gbestx,gbestfitness,gbesthistory]=GA_TSP(popsize,dimension,maxiter)
%% GA_TSP算法: 遗传算法解决TSP旅行商问题
% -------------------------------------------------------------------------
%       算法参数信息说明
% -------------------------------------------------------------------------
% popsize   ＿种群大小
% dimension ＿城市路径（如1,5,4,8,7,20,...)
% ncity     ＿城市的数盿测试问题的规模
% maxiter   ＿循环迭代次数
% pc个      ＿交叉概率
% pm:       ＿变异概率
% -------------------------------------------------------------------------

%% 准备工作
workpath = pwd; %保存当前路径

% 0. 创建pic目录（若不存在）
if ~exist('pic', 'dir')
    mkdir('pic');
end

% 1.预分配存储空间
pop=zeros(popsize,dimension);   %上一代种群
newpop=zeros(popsize,dimension);%下一代种群

fitness=rand(1,popsize);   %上一代种群适应度
newfitness=rand(1,popsize);%下一代种群适应度

% 2,加载城市地图信息
load china;                          % 中国地图信息
plotcities(province, border, city);  % 绘制中国地图

% 3. 获取城市规模及距离矩阵
dimension = length(city);            % 获取城市数目
disMatrix = distancematrix(city);    %获得城市间的距离矩阵 

% 5. 遗传算法参数设置
pc = 0.8;  %交叉概率
pm = 0.5;  %变异概率

% 6.TSP问题的信息（初始化城市路径gbestx，及路径的长度gbestfitness)
gbestfitness= inf; %全局最佳适应度初始化为最大（针对最小优化问题)
gbestx = zeros(1,dimension);   % 全局最佳位置向量，存储城市的序号
gbesthistory = zeros(1,maxiter);% 记录各迭代最佳路径长度数值

% -------------------------------------------------------------------------

%% 第一步： 种群初始化
for i = 1:popsize
    pop(i,:)= randperm(dimension);
    % 计算个体适应度（即路径总的长度)
    fitness(i)=Fitness(pop(i,:),disMatrix); 
    
    % 更新全局最优解
    if fitness(i)<gbestfitness
        gbestfitness = fitness(i);
        gbestx(:)=pop(i,:);
    end
end
 plotroute(city,gbestx,gbestfitness, 0);

% -------------------------------------------------------------------------
%% 第二步：循环迭代
for iter =1:maxiter
    %----------------------三大遗传操作---------------------------------
   
    %1. 选择操作：计算个体的选择概率，并选出popsize个个使
    [newpop] =selection(pop,fitness);
    
    %2. 将新的种群按照概率pc执行交叉操作（交叉前后，元素不能重复＿
    [newpop]= crossoverPMX(newpop,pc);
    
    %3. 将新的种群按照概率pm执行变异操作
    [newpop]= mutation(newpop,pm);
    
    %----------------------适应度计算----------------------------------
     for i=1:popsize
         % 计算新种群适应度
         newfitness(i)=Fitness(newpop(i,:),disMatrix); 
         %更新种群朿??路径信息
         if  newfitness(i)<gbestfitness
             gbestfitness = newfitness(i);
             gbestx(:) = newpop(i,:);
         end
    end

    %4.更新种群朿??路径信息
    gbesthistory(iter)= gbestfitness;
    fprintf('GA算法,迭代到第%d代，TSP路径长度 = %e\n',iter,gbestfitness);
    
    %5. 种群合并,排序，淘汰
     mergepop=[pop;newpop];
     fit=[fitness,newfitness];
     [topfit,topindex]=sort(fit);
     
     pop(1:popsize,:)=mergepop(topindex(1:popsize),:);
     fitness=topfit(1:popsize);
    %----------------------图形绘制--------------------------------- 
    plotroute(city,gbestx,gbestfitness, iter);
    if rem(iter,maxiter)== 0
        title('TSP 问题（中国）');
        xlabel('城市横坐标');
        ylabel('城市纵坐标');
        filename = strcat('pic\','tsp_map_iter_',num2str(iter));
        saveas(gcf,filename,'png');
    end
    cd(workpath);
  
    if iter == maxiter
        disp(['计算得到的TSP问题城市序列为:',num2str(gbestx)]);
    end
    
end %迭代结束

saveas(gcf,'tsp_map','png');
end




