function Demo_motion_deblur(fileAddress, len, theta, IterNum)
    orig_img = imread(fileAddress);
    
    lucy = deblur(orig_img, len, theta, IterNum);
    figure, imshow(cat(2, orig_img(:, :, 1), lucy)), title('运动模糊恢复');
end

function lucy = deblur(orig_img, len, theta, IterNum)
    if size(orig_img, 3) == 3
        orig_img = orig_img(:, :, 1);
    end
    %创建运动模糊的psf
    est_psf = fspecial('motion', len, theta);

    % 使用 edgetaper 平滑图像边缘，减少环形伪影
    orig_img = edgetaper(orig_img, est_psf);

    % 调用Lucy-Richardson 去卷积函数
    lucy = my_deconvlucy(orig_img, est_psf, IterNum);
end

function lucy = my_deconvlucy(orig_img, psf, num_iterations)
    psf_flipped = rot90(psf, 2); 
    lucy = double(orig_img);
    orig_img = double(orig_img);

    for k = 1:num_iterations
        % L_k ⊗ H
        estimated_blur = imfilter(lucy, psf, 'conv', 'same');

        % I / (L_k ⊗ H)，避免除以零
        ratio = orig_img ./ max(estimated_blur, 1e-6);

        % L_k+1 = L_k .* (I / (L_k ⊗ H)) ⊗ H^T
        correction = imfilter(ratio, psf_flipped, 'conv', 'same');
        lucy = lucy .* correction;
        if mod(k, 5) == 0
            fprintf('Iteration %d/%d complete\n', k, num_iterations);
        end
    end
    lucy = uint8(lucy); 
end
