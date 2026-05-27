# 第二章实验报告 MATLAB 代码说明

本目录存放《第二章 智能优化基础实验报告》的配套 MATLAB 程序。代码用于完成两个实验：

1. 旅行商问题 TSP 的穷举求解与运行时间分析。
2. 算法 A、B、C、D 在 F1 函数上的性能统计分析。

## 运行方式

在 MATLAB 中进入本目录：

```matlab
cd('D:\CI\CI2026\第2章 智能优化基础(The Foundations of  Optimization)\报告代码')
```

推荐运行分文件版本：

```matlab
chapter2_run_all
```

也可以运行单文件版本：

```matlab
chapter2_report_singlefile
```

程序会自动读取上级目录中的真实实验数据：

```text
../实验2：智能优化算法性能分析/实验数据结果/Results_A.mat
../实验2：智能优化算法性能分析/实验数据结果/Results_B.mat
../实验2：智能优化算法性能分析/实验数据结果/Results_C.mat
../实验2：智能优化算法性能分析/实验数据结果/Results_D.mat
```

运行结果会保存到：

```text
../实验报告输出/
```

## 文件说明

| 文件名 | 作用 |
|---|---|
| `chapter2_run_all.m` | 分文件版本的主入口程序。依次调用 TSP 实验函数和算法性能分析函数，并输出结果表。 |
| `chapter2_report_singlefile.m` | 单文件可运行版本。把所有核心函数写在一个 `.m` 文件中，便于复制、提交或单独运行。 |
| `run_tsp_experiment.m` | 实验 1 主函数。随机生成城市坐标，调用穷举算法求解 TSP，统计不同城市数量下的运行时间，并保存图表。 |
| `brute_force_tsp.m` | TSP 穷举求解函数。固定起点城市，枚举其余城市的所有排列，返回最短路径、最短距离和枚举路径数。 |
| `analyze_optimizer_results.m` | 实验 2 主函数。读取算法 A、B、C、D 的 `.mat` 数据，计算均值、标准差、最佳值、最差值，绘制箱线图和收敛曲线，并进行 ranksum 显著性检验。 |
| `load_numeric_matrix_from_mat.m` | `.mat` 数据读取辅助函数。自动从 `.mat` 文件中提取最大的二维数值矩阵，避免依赖固定变量名。 |
| `export_figure.m` | 图片保存辅助函数。将当前 MATLAB 图窗保存为 PNG，并尽量隐藏坐标区工具栏。 |

## 输出文件说明

运行成功后，`../实验报告输出/` 中会生成以下文件：

| 文件名 | 内容 |
|---|---|
| `task1_tsp_summary.csv` | TSP 实验统计表，包括城市数量、枚举路径数、最短距离、运行时间和最优路径。 |
| `task1_tsp_runtime.png` | TSP 城市数量、枚举路径数与运行时间关系图。 |
| `task1_tsp_best_route.png` | TSP 最短闭合路径示例图。 |
| `task2_summary.csv` | 算法 A、B、C、D 的收敛精度统计表，包括 mean、std、best、worst。 |
| `task2_boxplot.png` | 算法 A、B、C、D 最终最佳适应度箱线图。 |
| `task2_convergence.png` | 算法 A、B、C、D 在 F1 函数上的平均收敛曲线。 |
| `task2_ranksum.csv` | 算法两两 ranksum 显著性检验结果。 |

## 代码结构

分文件版本的调用关系如下：

```text
chapter2_run_all.m
├─ run_tsp_experiment.m
│  ├─ brute_force_tsp.m
│  └─ export_figure.m
└─ analyze_optimizer_results.m
   ├─ load_numeric_matrix_from_mat.m
   └─ export_figure.m
```

`chapter2_report_singlefile.m` 与上面的功能一致，但所有函数都集中在一个文件中。

## 注意事项

1. `Results_A.mat` 到 `Results_D.mat` 必须保存在课程原始目录 `实验2：智能优化算法性能分析/实验数据结果/` 下。
2. TSP 穷举法的复杂度为阶乘级，代码默认只测试 `N = 4:10`，不建议随意调到很大的城市数量。
3. 实验 2 中 F1 是最小化问题，因此适应度值越小，表示算法性能越好。
4. 如果 MATLAB 没有 `ranksum` 函数，程序会使用内置的 Mann-Whitney U 检验近似实现作为备用方案。

