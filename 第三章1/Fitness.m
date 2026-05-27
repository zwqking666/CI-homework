function totalLen=Fitness(individual,disMatrix)
%% 计算个体对应的tsp路径长度,即个体的适应度
% individual: 个体，代表一条路径，其元素为城市序号，如[1,5,2,6，...,10]


%1.累加前n-1个城市的间的路径长度
len=length(individual);
totalLen=0.0;
for i = 1:len-1
    totalLen = totalLen + disMatrix(individual(i),individual(i+1));
end

%2. 继续累加1个首尾路径的长度
totalLen = totalLen + disMatrix(individual(1),individual(len));
end