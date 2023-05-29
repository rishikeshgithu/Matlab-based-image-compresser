function ProjectAlpha07()
    % Create a figure window
    fig = figure('Name', 'Image Compression GUI', 'Position', [100 100 800 400], 'SizeChangedFcn', @(src,~) resizeGUI(src), 'Resize', 'off', 'WindowStyle', 'normal', 'WindowButtonDownFcn', @(src,~) disableMaximize(src));
    

    % Create a panel to hold the image display
    panel = uipanel(fig, 'Position', [0.05 0.1 0.4 0.8]);

    % Create axes for displaying the images
    axesOriginal = axes('Parent', panel, 'Position', [0 0 0.5 1]);
    axesCompressed = axes('Parent', panel, 'Position', [0.5 0 0.5 1]);

    % Create a button for compressing the image
    compressButton = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Compress Image',...
        'Position', [500 200 120 30], 'Callback', @compressImage, 'Tooltip', 'Click to compress the image');

    % Create a button for uploading an image
    uploadButton = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Upload Image',...
        'Position', [500 150 120 30], 'Callback', @uploadImage, 'Tooltip', 'Click to upload an image');

    % Create labels and titles
    uicontrol(fig, 'Style', 'text', 'String', 'Image Compressor', 'Position', [300 380 200 20], 'FontWeight', 'bold', 'FontSize', 14);
    originalSizeLabel = uicontrol(fig, 'Style', 'text', 'String', '', 'Position', [600 350 200 20]);
    compressedSizeLabel = uicontrol(fig, 'Style', 'text', 'String', '', 'Position', [600 320 200 20]);
    spaceSavedLabel = uicontrol(fig, 'Style', 'text', 'String', '', 'Position', [600 290 200 20]);

    % Load the default image
    img = imread('image.jpeg');

    % Display the original image
    axes(axesOriginal);
    imshow(img);
    title('Original Image');

    % Callback function for the compressButton
    function compressImage(~, ~)
        try
            % Convert the image to grayscale
            img_gray = rgb2gray(img);

            % Convert the grayscale image to double precision
            img_gray = im2double(img_gray);

            % Convert the grayscale image to the frequency domain using FFT
            f = fft2(img_gray);

            % Shift the zero-frequency component to the center of the spectrum
            fshift = fftshift(f);

            % Compute the magnitude spectrum
            magnitude = log(1 + abs(fshift));

            % Set a threshold value for frequency filtering
            threshold = 0.1 * max(magnitude(:));

            % Perform frequency filtering by setting coefficients with magnitude below the threshold to zero
            fshift_filtered = fshift .* (magnitude > threshold);

            % Shift the zero-frequency component back to the top-left corner of the spectrum
            f_filtered = ifftshift(fshift_filtered);

            % Convert the filtered spectrum back to the spatial domain using inverse FFT
            img_gray_filtered = real(ifft2(f_filtered));

            % Rescale the filtered grayscale image to the range [0, 1]
            img_gray_filtered = imadjust(img_gray_filtered, [], [], 0.5);

            % Convert the compressed color image to double precision
            img_compressed = im2double(img);

            % Perform color balance adjustment by scaling the R, G, and B channels of the compressed image
            img_compressed(:,:,1) = img_compressed(:,:,1) .* (img_gray_filtered ./ mean2(img_gray_filtered));
            img_compressed(:,:,2) = img_compressed(:,:,2) .* (img_gray_filtered ./ mean2(img_gray_filtered));
            img_compressed(:,:,3) = img_compressed(:,:,3) .* (img_gray_filtered ./ mean2(img_gray_filtered));

            % Rescale the compressed color image to the range [0, 1]
            img_compressed = imadjust(img_compressed, [], [], 0.5);

            % Convert the compressed color image back to the uint8 data type
            img_compressed = im2uint8(img_compressed);

            % Display the compressed image
            axes(axesCompressed);
            imshow(img_compressed);
            title('Compressed Image');

            % Save the compressed image to a file in JPEG format
            imwrite(img_compressed, 'image_compressed.jpg', 'JPEG');

            % Calculate file sizes
            originalSize = dir('image.jpeg').bytes;
            compressedSize = dir('image_compressed.jpg').bytes;

            % Update the size labels
            originalSizeLabel.String = sprintf('Original Size: %d bytes', originalSize);
            compressedSizeLabel.String = sprintf('Compressed Size: %d bytes', compressedSize);

            % Calculate space saved
            spaceSaved = originalSize - compressedSize;
            spaceSavedLabel.String = sprintf('Space Saved: %d bytes', spaceSaved);
        catch
            errordlg('Error occurred during compression.', 'Compression Error', 'modal');
        end
    end

    % Callback function for the uploadButton
    function uploadImage(~, ~)
        [filename, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files (*.jpg, *.jpeg, *.png, *.bmp)'}, 'Select Image');
        if filename ~= 0
            img = imread(fullfile(path, filename));
            axes(axesOriginal);
            imshow(img);
            title('Original Image');
        end
    end

    % Resize GUI elements when the figure is resized or maximized
    function resizeGUI(src)
        % Get the current figure size
        figPos = src.Position;

        % Update the panel position
        panel.Position = [0.05 0.1 0.4*figPos(3)/800 0.8];

        % Update the button positions
        compressButton.Position = [500*figPos(3)/800 200*figPos(4)/400 120*figPos(3)/800 30*figPos(4)/400];
        uploadButton.Position = [500*figPos(3)/800 150*figPos(4)/400 120*figPos(3)/800 30*figPos(4)/400];

        % Update the axes positions
        axesOriginal.Position = [0 0 0.5*figPos(3)/800 1*figPos(4)/400];
        axesCompressed.Position = [0.5*figPos(3)/800 0 0.5*figPos(3)/800 1*figPos(4)/400];

        % Update the label positions
        originalSizeLabel.Position = [600*figPos(3)/800 350*figPos(4)/400 200*figPos(3)/800 20*figPos(4)/400];
        compressedSizeLabel.Position = [600*figPos(3)/800 320*figPos(4)/400 200*figPos(3)/800 20*figPos(4)/400];
        spaceSavedLabel.Position = [600*figPos(3)/800 290*figPos(4)/400 200*figPos(3)/800 20*figPos(4)/400];

        % Update the label positions
        uicontrol(fig, 'Style', 'text', 'String', 'Original Image', 'Position', [60*figPos(3)/800 370*figPos(4)/400 120*figPos(3)/800 20*figPos(4)/400], 'FontWeight', 'bold');
        uicontrol(fig, 'Style', 'text', 'String', 'Compressed Image', 'Position', [400*figPos(3)/800 370*figPos(4)/400 120*figPos(3)/800 20*figPos(4)/400], 'FontWeight', 'bold');
        uicontrol(fig, 'Style', 'text', 'String', 'Image Compressor', 'Position', [300*figPos(3)/800 380*figPos(4)/400 200*figPos(3)/800 20*figPos(4)/400], 'FontWeight', 'bold', 'FontSize', 14);
    end

    % Function to disable the maximize button
    function disableMaximize(src)
        src.WindowState = 'normal';
    end

end
