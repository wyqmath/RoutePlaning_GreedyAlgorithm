% 读取数据
data = readtable('cleaned_data.csv', 'PreserveVariableNames', true);

% 将中文列名转换为英文（如果还没有转换）
data.Properties.VariableNames{'名字'} = 'Name';
data.Properties.VariableNames{'链接'} = 'Link';
data.Properties.VariableNames{'地址'} = 'Address';
data.Properties.VariableNames{'介绍'} = 'Introduction';
data.Properties.VariableNames{'开放时间'} = 'OpenTime';
data.Properties.VariableNames{'图片链接'} = 'ImageLink';
data.Properties.VariableNames{'评分'} = 'Rating';
data.Properties.VariableNames{'建议游玩时间'} = 'SuggestedPlayTime';
data.Properties.VariableNames{'建议季节'} = 'SuggestedSeason';
data.Properties.VariableNames{'门票'} = 'Ticket';
data.Properties.VariableNames{'小贴士'} = 'Tips';
data.Properties.VariableNames{'Page'} = 'Page';
data.Properties.VariableNames{'来源城市'} = 'SourceCity';

% 找出最高评分
maxRating = max(data.Rating);

% 统计每个城市获得最高评分的景点数量
maxRatingData = data(data.Rating == maxRating, :);
cityCounts = groupcounts(maxRatingData, 'SourceCity');

% 按照景点数量降序排序
cityCounts = sortrows(cityCounts, 'GroupCount', 'descend');

% 提取前10个城市
top10Cities = cityCounts(1:10, :);

% 可视化前10个城市的结果
figure;
bar(top10Cities.GroupCount, 'FaceColor', 'flat');

% 为每个城市指定不同的颜色
colors = lines(10); % 生成10种颜色
for k = 1:10
    bar(k).CData = colors(k, :);
end

% 设置图表标题和轴标签
title('Top 10 Cities with the Most Attractions Having the Highest Score', 'FontSize', 14);
xlabel('City', 'FontSize', 12);
ylabel('Number of Attractions with the Highest Score', 'FontSize', 12);

% 设置X轴刻度标签
set(gca, 'XTickLabel', top10Cities.SourceCity, 'XTick', 1:10, 'XTickLabelRotation', 45);

% 添加图例
legend('Number of Attractions', 'Location', 'northeastoutside');

% 设置背景颜色
set(gca, 'Color', [0.9, 0.9, 0.9]);

% 添加网格线
grid on;

% 显示最高评分和全国获评这个最高评分的景点数量
disp(['The highest score (BS) is: ', num2str(maxRating)]);
disp(['The number of attractions with the highest score (BS) is: ', num2str(height(maxRatingData))]);

% 保存图表为图片文件
saveas(gcf, 'top10_cities_highest_score.png');

% 保存前10个城市的表格到文件
writetable(top10Cities, 'top10_cities_highest_score.csv');

