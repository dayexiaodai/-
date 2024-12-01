function PDE_Inpaint(imgPath, maskPath,iteration,thresholdValue)

% 基于偏微分方程(PDE)的图像修复，通过对图像中的缺失区域进行插值，完成对图像的修复

img = imread(imgPath);
Mask = imread(maskPath);

% 灰度图像，通道数：1
% 彩色图像(RGB图像)，通道数：3
[~, ~, channelNum] = size(Mask); % 获取掩码图像的通道数 

% 检查掩码图像是否为灰度图像
if channelNum > 1    
    Mask = rgb2gray(Mask); % 转换为灰度图像  
end  

% 将掩膜图像转换为二值图像。imbinarize 函数会将图像转为黑色0和白色1
% Mask中的白色部分1表示修复区域
Mask = imbinarize(Mask);

outpImg = img;

% maskbar 是掩膜的反转(即修复区域为黑色0，背景为白色1)
maskbar = 1-Mask;

% 应用 maskbar 到 outpImg 图像，将修复区域的像素值改为黑色0
outpImg(:,:,1) = ((outpImg(:,:,1)).*uint8(maskbar));
outpImg(:,:,2) = ((outpImg(:,:,2)).*uint8(maskbar));
outpImg(:,:,3) = ((outpImg(:,:,3)).*uint8(maskbar));

figure('Name', '原始图像', 'NumberTitle', 'off');
imshow(uint8(outpImg));
title('原始图像');

Lapla = zeros(size(outpImg));

for iter=1:iteration
    % fspecial('laplacian') 创建一个Laplacian滤波器，通常用于边缘检测
    % Laplacian滤波器通过计算图像中像素灰度值的二阶导数，来检测图像的快速变化区域，即边缘
    filter = fspecial('laplacian');

    % imfilter函数 对每个颜色通道应用Laplacian滤波器
    % L(:,:,1) L(:,:,2) L(:,:,3) 分别存储滤波后的红色 绿色 蓝色通道
    % Lapla是一个三维数组，包含经过Laplacian滤波的图像各通道
    Lapla(:,:,1) = imfilter(outpImg(:,:,1),filter);
    Lapla(:,:,2) = imfilter(outpImg(:,:,2),filter);
    Lapla(:,:,3) = imfilter(outpImg(:,:,3),filter);

    % imgradient函数 计算图像梯度的幅度和方向
    % 梯度幅度表示图像灰度变化的大小，通常用于边缘检测
    % dir_oImg_r 是图像梯度的方向
    [~,dir_oImg_r] = imgradient(outpImg(:,:,1));
    [~,dir_oImg_b] = imgradient(outpImg(:,:,3));
    [~,dir_oImg_g] = imgradient(outpImg(:,:,2));

    % mag_Lap_r 是Lapla各通道的梯度幅度，dir_Lap_r 是相应的梯度方向
    [mag_Lap_r,dir_Lap_r] = imgradient(Lapla(:,:,1));
    [mag_Lap_b,dir_Lap_b] = imgradient(Lapla(:,:,3));
    [mag_Lap_g,dir_Lap_g] = imgradient(Lapla(:,:,2));

    %--------------------处理梯度幅度--------------------
    % 归一化处理(最小值Min,最大值Max归一化)
    % 通过减去每个通道的最小值，确保所有像素值都是非负的(即最小值变为0)
    mag_Lap_r(:,:) = mag_Lap_r(:,:)-min(mag_Lap_r(:));
    mag_Lap_b(:,:) = mag_Lap_b(:,:)-min(mag_Lap_b(:));
    mag_Lap_g(:,:) = mag_Lap_g(:,:)-min(mag_Lap_g(:));

    % 通过将每个通道的元素乘以255再除以对应的最大值，将所有像素值归一化到0-255的范围
    %目的:处理后能获得更好的强度对比(增强对比度)
    mag_Lap_r(:,:) = mag_Lap_r(:,:)*255/max(mag_Lap_r(:));
    mag_Lap_b(:,:) = mag_Lap_b(:,:)*255/max(mag_Lap_b(:));
    mag_Lap_g(:,:) = mag_Lap_g(:,:)*255/max(mag_Lap_g(:));

    %--------------------处理梯度方向--------------------
    % 归一化处理，(减去最小值，确保最小值都变为0)
    % 目的:(1)去除偏移。(2)增强对比度，使图像质量更高，细节更明显
    dir_oImg_r(:,:) = dir_oImg_r(:,:)-min(dir_oImg_r(:));
    dir_oImg_b(:,:) = dir_oImg_b(:,:)-min(dir_oImg_b(:));
    dir_oImg_g(:,:) = dir_oImg_g(:,:)-min(dir_oImg_g(:));

    dir_Lap_r(:,:) = dir_Lap_r(:,:)-min(dir_Lap_r(:));
    dir_Lap_b(:,:) = dir_Lap_b(:,:)-min(dir_Lap_b(:));
    dir_Lap_g(:,:) = dir_Lap_g(:,:)-min(dir_Lap_g(:));

    % 新的梯度方向 (New_dir_r, New_dir_g, New_dir_b) 等于 归一化后的图像梯度方向 减 归一化后的Lapla梯度方向
    % 目的:(1)去除高频噪声，获得更平滑的结果。(2)突出重要特征
    New_dir_r = dir_oImg_r-dir_Lap_r;
    New_dir_b = dir_oImg_b-dir_Lap_b;
    New_dir_g = dir_oImg_g-dir_Lap_g;

    outpImg = double(outpImg);

    % 用两层循环遍历图像的每一个像素点，除了边缘的像素(第3行到倒数第3行，第3列到倒数第3列，避免边界溢出)
    for i=3:size(img,1)-2
        for j=3:size(img,2)-2
            % 检查当前像素 (i,j) 是否在 Mask 的白色部分1(修复区域)
            if Mask(i,j) == 1

                % cosd(New_dir_r(i,j)) 表示梯度方向的影响
                % 将每个颜色通道的梯度幅度 * 梯度方向的影响，得到每个颜色通道(红，蓝，绿)的梯度影响量
                gradInflu_r = (mag_Lap_r(i,j))*cosd(New_dir_r(i,j));
                gradInflu_b = (mag_Lap_b(i,j))*cosd(New_dir_b(i,j));
                gradInflu_g = (mag_Lap_g(i,j))*cosd(New_dir_g(i,j));

                % 计算当前像素 (i,j) 周围8个邻居像素的红，绿，蓝通道的平均值，后面会利用这个平均值更新该像素
                avg_r = (outpImg(i-1,j-1,1)+outpImg(i+1,j+1,1)+outpImg(i,j-1,1)+outpImg(i-1,j,1)+outpImg(i,j+1,1)+outpImg(i+1,j,1)+outpImg(i-1,j+1,1)+outpImg(i+1,j-1,1))/8;
                avg_g = (outpImg(i-1,j-1,2)+outpImg(i+1,j+1,2)+outpImg(i,j-1,2)+outpImg(i-1,j,2)+outpImg(i,j+1,2)+outpImg(i+1,j,2)+outpImg(i-1,j+1,2)+outpImg(i+1,j-1,2))/8;
                avg_b = (outpImg(i-1,j-1,3)+outpImg(i+1,j+1,3)+outpImg(i,j-1,3)+outpImg(i-1,j,3)+outpImg(i,j+1,3)+outpImg(i+1,j,3)+outpImg(i-1,j+1,3)+outpImg(i+1,j-1,3))/8;

                % 通过改变denom的值，可调节修复效果的强度
                denom = 15;

                % abs函数，确保梯度影响值为正值
                gradInflu_r = abs(gradInflu_r);
                gradInflu_b = abs(gradInflu_b);
                gradInflu_g = abs(gradInflu_g);

                % 增大正阈值threshold: 亮度偏高或偏低的像素也会被更新
                % 因此，正阈值越大，图像越平滑，越可能导致图像细节丢失(模糊)，特别是在边缘和细节丰富的区域
                % 阈值: 正阈值越大，修复区域越白。负阈值越小，修复区域越黑。(一般图像，阈值为0效果较好)
                
                % 当 thresh 为较大的正值时，更多的像素会被更新
                % 即使当前像素的值与周围邻居的平均值之间的差异较大，当前像素也会进行更新
                % 这会导致修复区域的颜色更接近白色或亮色
                % 当 thresh 为较小的负值时，只有当当前像素的值与周围邻居的平均值之间的差异非常小(即接近于负值)时，当前像素才会进行更新
                % 这会导致修复区域几乎不更新原始像素值(修复区域的原始像素值为黑色0)，从而导致修复区域为黑色

                thresh = thresholdValue; % thresh 0 for letters
 
                % 小于阈值，则更新当前像素的红色，绿色，蓝色通道的值
                if (outpImg(i,j,1)+gradInflu_r/denom-avg_r) < thresh
                    % 将当前像素的颜色向周围像素的均值(avg_r，avg_g，avg_b)靠近
                    outpImg(i,j,1) = outpImg(i,j,1)+gradInflu_r/denom;
                end
                if (outpImg(i,j,2)+gradInflu_g/denom-avg_g) < thresh
                    outpImg(i,j,2) = outpImg(i,j,2)+gradInflu_g/denom;
                end
                if (outpImg(i,j,3)+gradInflu_b/denom-avg_b) < thresh
                    outpImg(i,j,3) = outpImg(i,j,3)+gradInflu_b/denom;
                end
            end
        end
    end
end

figure('Name', 'Laplacian滤波后的图像', 'NumberTitle', 'off');
imshow(uint8(Lapla));
title('Laplacian滤波后的图像');

figure('Name', 'PDE修复后的图像', 'NumberTitle', 'off');
imshow(uint8(outpImg));
titleStr = sprintf('PDE修复后的图像，迭代次数: %d，阈值: %d', iteration, thresholdValue);  
title(titleStr);  

uicontrol('Style', 'pushbutton', 'String', '保存图像', ...  
                     'Units', 'normalized', ...  
                     'Position', [0.35, 0.02, 0.3, 0.1], ... 
                     'FontSize', 10,...
                     'Callback', @(src, event) saveImage(outpImg,iteration,thresholdValue));
end

function saveImage(outpImg,iteration,thresholdValue)
% 保存处理后的图像
baseFileName = 'PDE';  % 基础文件名  
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

fullFileName = fullfile(targetDir, [baseFileName,'-iter',num2str(iteration), 'thresh',num2str(thresholdValue),'_', timeStamp, suffix]);
imwrite(uint8(outpImg), fullFileName);

msgbox('处理后的图像已保存');
end














