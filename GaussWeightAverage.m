function GaussWeightAverage(imgPath, maskPath,filter,iterations)

img = imread(imgPath);
mask = imread(maskPath);

unmaskedRegion= createUnmaskedRegion(imgPath, maskPath);
unmaskedRegion = double(unmaskedRegion);

gauss=filter;
[h,w,~] = size(img);

% 灰度图像，通道数：1
% 彩色图像(RGB图像)，通道数：3
[~, ~, channelNum] = size(mask); % 获取掩码图像的通道数

% 检查掩码图像是否为灰度图像
if channelNum > 1
    mask = rgb2gray(mask); % 转换为灰度图像
end

% 二值化：将掩码转换为二值图像，白色区域为 1(需要修复的区域)，黑色区域为 0
mask = imbinarize(mask);

% 通过 1 - mask 生成反掩码 maskbar，即把掩码中的白色区域变为黑色，黑色区域变为白色(maskbar 中修复区域为黑色)
maskbar = 1-mask;

% 创建一个大小与图像相同的零矩阵 M，用于存储掩码的颜色通道信息
M = zeros(h,w,3);

% 如果掩码是 3通道(即彩色图像)，直接将掩码赋值给 M
% 否则，通过循环将掩码复制到 M 的三个通道中(即生成一个三通道掩码)
if channelNum == 3
    M = mask;
else
    for i = 1:3
        M(:,:,i) = mask(:,:);
    end
end

% 获取 gauss 矩阵的行数 row_g 和列数 column_g
[row_g,column_g] = size(gauss);

% 三通道零矩阵：包含三个颜色通道的矩阵，每个通道的元素都是零(所有像素值均为零，代表黑色)
% 创建一个三通道零矩阵 G，并将 gauss 复制到所有三个通道
G = zeros(row_g, column_g, 3);
for i = 1:3
    G(:,:,i) = gauss(:,:);
end

% 使用 maskbar 将原始图像的颜色分量与掩码相乘，生成 tempImg，以保留未被掩盖的区域的值
tempImg(:,:,1) = uint8(maskbar).*img(:,:,1);
tempImg(:,:,2) = uint8(maskbar).*img(:,:,2);
tempImg(:,:,3) = uint8(maskbar).*img(:,:,3);

% 将 tempImg 数据类型转换为 double
tempImg = double(tempImg);

% 迭代进行高斯加权平均
% 外层循环：针对指定的迭代次数进行循环
for iter = 1:iterations
    % 内层循环：遍历图像中所有的像素(不包括边缘的像素)
    for i = 3:h-2
        for j = 3:w-2
            % 如果当前像素在掩码中是白色区域 1(需要修复的区域)
            if mask(i,j) == 1
                % 提取当前像素周围的 3x3 的邻域 neighbour
                neighbour = tempImg(i-1:i+1,j-1:j+1,:);

                % 应用高斯滤波：将邻域的颜色分量应用高斯权重，生成加权值 neighWeight_1
                neighWeight_1 = neighbour(:,:,1).*gauss;
                neighWeight_2 = neighbour(:,:,2).*gauss;
                neighWeight_3 = neighbour(:,:,3).*gauss;

                sumGauss = sum(gauss(:));   % 计算高斯矩阵的所有元素的总和

                % 计算新的像素值：通过 sum 函数计算加权平均，并更新 tempImg 中对应的像素值
                tempImg(i,j,1) = sum(neighWeight_1(:))/sumGauss;
                tempImg(i,j,2) = sum(neighWeight_2(:))/sumGauss;
                tempImg(i,j,3) = sum(neighWeight_3(:))/sumGauss;
            end
        end
    end
end

% 将 tempImg 与掩码 M 相乘，保留修复过的区域
added = tempImg.*M;

% 将未掩盖区域和 added 相加，得到最终修复效果 inpainted
inpainted = unmaskedRegion + added;

% figure, imshow(uint8(img)); title('Original');
% figure, imshow(uint8(added)); title('Added');

% figure, imshow(uint8(inpainted)); title('Without Diffusion Barriers');

figure('Name', '原始图像', 'NumberTitle', 'off');
imshow(uint8(img));
title('原始图像');

figure('Name', 'Weight修复后的图像', 'NumberTitle', 'off');
imshow(uint8(inpainted));
titleStr = sprintf('Weight修复后的图像，迭代次数: %d', iterations);
title(titleStr);

uicontrol('Style', 'pushbutton', 'String', '保存图像', ...
    'Units', 'normalized', ...
    'Position', [0.35, 0.02, 0.3, 0.1], ...
    'FontSize', 10,...
    'Callback', @(src, event) saveImage(inpainted,iterations));
end

function saveImage(outpImg,iterations)
% 保存处理后的图像
baseFileName = 'Weight';  % 基础文件名
timeStamp = datestr(now,'yyyymmdd-HHMMSS');  % 获取当前时间的字符串
suffix = '.png';

% 目标保存路径
targetDir = 'C:\Users\86173\Desktop\数图课设\test';

% 检查目标路径是否存在
if ~exist(targetDir, 'dir')
    % 如果不存在，使用当前文件的目录
    currentDir = fileparts(mfilename('fullpath'));  % 获取当前文件的目录
    targetDir = currentDir;  % 设置为当前目录
end

% 构建完整的文件名
fullFileName = fullfile(targetDir, [baseFileName, '-iter', num2str(iterations), '_', timeStamp, suffix]);
imwrite(uint8(outpImg), fullFileName);

msgbox('处理后的图像已保存');
end

function [unmaskedRegion]=createUnmaskedRegion(imgPath, maskPath)

img = double(imread(imgPath));
mask = imread(maskPath);

% 灰度图像，通道数：1
% 彩色图像(RGB图像)，通道数：3
[~, ~, channelNum] = size(mask); % 获取掩码图像的通道数

% 检查掩码图像是否为灰度图像
if channelNum > 1
    mask = rgb2gray(mask); % 转换为灰度图像
end

% 二值化：将掩码转换为二值图像
mask = imbinarize(mask);

% imcomplement 函数：对输入图像的每个像素值进行取反。在二值图像中：
% 原来是 0 的像素变为 1(黑色变成白色)
% 原来是 1 的像素变为 0(白色变成黑色)
mask = imcomplement(mask);

% 从原始图像 img 中提取红色通道的值，并将其与 mask 进行逐元素相乘
% 由于 mask 中的白色区域1 保留了对应的红色通道值，黑色区域0 将使得对应区域的值为0
% 结果是 unmaskedRegion(:,:,1) 中只保留了未被掩码覆盖的红色通道像素
unmaskedRegion(:,:,1) = img(:,:,1).*mask;
unmaskedRegion(:,:,2) = img(:,:,2).*mask;
unmaskedRegion(:,:,3) = img(:,:,3).*mask;

% 结果：图像的未被掩码覆盖的区域被保留下来，被掩码覆盖的区域被设定为0(黑色)
end



