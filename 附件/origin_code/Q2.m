% 读取数据
data = readtable('问题二数据集.xlsx', 'VariableNamingRule', 'preserve');

% 数据清洗和预处理
data = rmmissing(data); % 删除缺失值

% 分类
city_scale = data{:, {'线路密度 (km/km²)', '高速公路里程 (km)', '机场航班数量'}};
environment = data{:, {'AQI', '绿化覆盖率 (%)', '废水处理率 (%)', '废气处理率 (%)', '垃圾分类处理率 (%)'}};
culture = data{:, {'历史遗迹数量', '博物馆数量', '文化活动频次', '文化设施数量'}};
transport = data{:, {'公共交通覆盖率 (%)', '线路密度 (km/km²)'}};
climate = data{:, {'年平均气温 (℃)', '年降水量 (mm)', '适宜旅游天数', '空气湿度 (%)'}};
food = data{:, {'餐馆数量', '特色美食数量', '美食活动频次'}};

% KMO检验和降维
categories = {city_scale, environment, culture, transport, climate, food};
category_names = {'City Scale', 'Environment', 'Culture', 'Transport', 'Climate', 'Food'};
scores = zeros(size(data, 1), length(categories));

for i = 1:length(categories)
    category = categories{i};
    kmoValue = kmo_test(category);
    
    if kmoValue > 0.6 % 假设通过KMO检验的阈值为0.6
        [~, score] = pca(category);
        scores(:, i) = score(:, 1);
    else
        % 使用基于熵权法的TOPSIS降维
        normalized_category = zscore(category);
        entropy = -sum(normalized_category .* log(normalized_category + eps)) / log(size(normalized_category, 1));
        weights = (1 - entropy) / sum(1 - entropy);
        ideal_solution = max(normalized_category);
        negative_solution = min(normalized_category);
        distance_to_ideal = sqrt(sum((normalized_category - ideal_solution).^2, 2));
        distance_to_negative = sqrt(sum((normalized_category - negative_solution).^2, 2));
        topsis_score = distance_to_negative ./ (distance_to_ideal + distance_to_negative);
        scores(:, i) = topsis_score;
    end
    
    % 可视化降维结果
    figure;
    if kmoValue > 0.6
        bar(score(:, 1));
        title(['PCA dimensionality reduction results - ', category_names{i}]);
    else
        bar(topsis_score);
        title(['TOPSIS dimensionality reduction results - ', category_names{i}]);
    end
    xlabel('City Index');
    ylabel('Score');
    grid on;
    saveas(gcf, ['dimensionality_reduction_', category_names{i}, '.png']);
end

% 综合评价模型构建（熵权法的TOPSIS）
normalized_data = zscore(scores);
entropy = -sum(normalized_data .* log(normalized_data + eps)) / log(size(normalized_data, 1));
weights = (1 - entropy) / sum(1 - entropy);
ideal_solution = max(normalized_data);
negative_solution = min(normalized_data);
distance_to_ideal = sqrt(sum((normalized_data - ideal_solution).^2, 2));
distance_to_negative = sqrt(sum((normalized_data - negative_solution).^2, 2));
topsis_score = distance_to_negative ./ (distance_to_ideal + distance_to_negative);

% 选出前50个城市
[~, sorted_index] = sort(topsis_score, 'descend');
top50_cities = data(sorted_index(1:50), :);

% 可视化结果
figure;

% 获取城市名称并转换为单元数组，以便在图表中使用
city_names = top50_cities.('来源城市');
city_names_cell = cellstr(city_names);

% 绘制柱状图
bar(topsis_score(sorted_index(1:50)));

% 设置X轴刻度标签并旋转
set(gca, 'XTick', 1:50, 'XTickLabel', city_names_cell, 'XTickLabelRotation', 45);

% 设置图表标题和轴标签
title('Top 50 Cities Most Attractive to Foreign Tourists');
xlabel('City');
ylabel('TOPSIS Score');
grid on;

% 保存结果
writetable(top50_cities, 'top50_cities.csv');
saveas(gcf, 'top50_cities.png');

% 输出排名结果为表格文件
full_ranking = data(sorted_index, :);
writetable(full_ranking, 'full_city_ranking.csv');