function Demo_out_of_focus_deblur(fileAddress, radius, smooth, dering)
    G = imread(fileAddress);
    F = OOF_deblur(G, radius, smooth, dering);
    figure, imshow(cat(2, G, F)), title('Out-of-focus Deblur');
end

function F = OOF_deblur(G, radius, smooth, dering)
    % 如果是彩色图像，则对每个通道分别进行处理
    if size(G, 3) == 3
        F = G;
        for c = 1 : 3
            F(:, :, c) = OOF_deblur(G(:, :, c), radius, smooth, dering);
        end
    else
        % 生成psf
        psf = zeros(size(G, 1), size(G, 2));
        [rows, cols] = size(psf);

        % 在中心生成一个半径为 radius 的白色圆形模糊核
        psf = insertShape(psf, 'FilledCircle', [(cols + 1)/ 2, (rows + 1)/ 2, radius], 'Color', 'white', 'Opacity', 1) * 255;
        psf = psf(:, :, 1);  % 提取单通道
        psf = psf ./ sum(sum(psf));  % 归一化PSF
        psf = fftshift(psf);  % 将低频移到中间
        psf_fft = fft2(psf);
        G_fft = fft2(G);
        
        % 防止环效应
        if strcmp(dering, 'On')
            for i = 1 : rows
                for j = 1 : cols
                    %用psf对模糊图像进行滤波，减少高频分量引起的环效应
                    G_fft(i, j) = G_fft(i, j) * real(psf_fft(i, j));
                end
            end
            %tmp保存滤波后的图像
            tmp = real(ifft2(G_fft));
            for i = 1 : rows
                for j = 1 : cols
                    if (i < radius) || (j < radius) || (i > rows - radius) || (j > cols - radius)
                        %只替换原始图像的边缘部分。边缘部分以psf半径为界限
                        G(i, j) = tmp(i, j);
                    end
                end
            end
        end

        % 使用 Wiener 去噪算法
        G_fft= fft2(G);
        K = (1.09 ^ smooth) / 10000;
        for i = 1 : rows
            for j = 1 : cols
                %|H(u,v)|^2
                energyValue = abs(psf_fft(i, j)) ^ 2;
                %H^(u,v) / (|H(u,v)|^2+K)
                wienerValue = real(psf_fft(i, j)) / (energyValue + K);
                %F(u,v) = H^(u,v)*G(u,v) / (|H(u,v)|^2+K)
                G_fft(i, j) = wienerValue * G_fft(i, j);
            end
        end
        %返回空域
        F = uint8(real(ifft2(G_fft)));
    end
end
