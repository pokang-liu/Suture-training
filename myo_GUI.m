  %% Video Display in a Custom User Interface
% This example shows how to display multiple video streams in a custom 
% graphical user interface (GUI).
%hold1  cut2  dig3  pull4  head99
%% Overview
% When working on a project involving video processing, we are often faced
% with creating a custom user interface. It may be needed for the purpose
% of visualizing and/or demonstrating the effects of our algorithms on the
% input video stream. This example illustrates how to create a figure
% window with two axes to display two video streams. It also shows how to
% set up buttons and their corresponding callbacks.

%   Copyright 2004-2014 The MathWorks, Inc.

%%
% The example is written as a function with the main body at the top and 
% helper routines in the form of 
% <matlab:helpview(fullfile(docroot,'toolbox','matlab','matlab_prog','matlab_prog.map'),'nested_functions') nested functions>
% below.
function VideoInCustomGUIExample()

%%
%%%%modify here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% Initialize the video reader.
heademg = 1034;%%%%%%%%%%%%%%%%%%modify here!
headgyro =262;%%%%%%%%%%%%%%%%%%modify here!
videoName = 'P-15';%%%%%%%%%%%%%%%%modify here!
viDir = ['P:\Desktop\郭柏伶\20180417\video\P\'  videoName  '.mp4'];
videoSrc = vision.VideoFileReader(viDir, 'ImageColorSpace', 'Intensity');
data_dir = 'P:\Desktop\郭柏伶\20180417\data\p\';
data_file = '15.csv';%%%%%%%%%%%%%%%%modify here!
vidObj=VideoReader(viDir);
%% 
% Create a figure window and two axes to display the input video and the
% processed video.
[hFig, hAxes] = createFigureAndAxes();

%%
% Add buttons to control video playback.
insertButtons(hFig, hAxes, videoSrc,vidObj);
%%
% I like global variables
angle = 0;
currentFrame = 0;
prevFrame = 0;
mTextBox = uicontrol('style','text');
labelArray = []
%% Result of Pressing the Start Button
% Now that the GUI is constructed, we trigger the play callback which
% contains the main video processing loop defined in the
% |getAndProcessFrame| function listed below. If you prefer to click on the
% |Start| button yourself, you can comment out the following line of code.
playCallback(findobj('tag','PBButton123'),[],videoSrc,vidObj,hAxes);

%%
% Note that each video frame is centered in the axis box. If the axis size
% is bigger than the frame size, video frame borders are padded with
% background color. If axis size is smaller than the frame size scroll bars
% are added.

%% Create Figure, Axes, Titles
% Create a figure window and two axes with titles to display two videos.
    function [hFig, hAxes] = createFigureAndAxes()

        % Close figure opened by last run
        figTag = 'CVST_VideoOnAxis_9804532';
        close(findobj('tag',figTag));

        % Create new figure
        hFig = figure('numbertitle', 'off', ...
               'name', 'Video In Custom GUI', ...
               'menubar','none', ...
               'toolbar','none', ...
               'resize', 'on', ...
               'tag',figTag, ...
               'renderer','painters', ...
               'position',[100 100 480 240]);

        % Create axes and titles
        hAxes.axis1 = createPanelAxisTitle(hFig,[0.1 0.2 0.6 0.8],'Original Video'); % [X Y W H]
        %hAxes.axis2 = createPanelAxisTitle(hFig,[0.5 0.2 0.36 0.6],'Rotated Video');
    end

%% Create Axis and Title
% Axis is created on uipanel container object. This allows more control
% over the layout of the GUI. Video title is created using uicontrol.
    function hAxis = createPanelAxisTitle(hFig, pos, axisTitle)

        % Create panel
        hPanel = uipanel('parent',hFig,'Position',pos,'Units','Normalized');

        % Create axis   
        hAxis = axes('position',[0 0 1 1],'Parent',hPanel); 
        hAxis.XTick = [];
        hAxis.YTick = [];
        hAxis.XColor = [1 1 1];
        hAxis.YColor = [1 1 1];
        % Set video title using uicontrol. uicontrol is used so that text
        % can be positioned in the context of the figure, not the axis.
        titlePos = [pos(1)+0.02 pos(2)+pos(3)+0.3 0.3 0.07];
        uicontrol('style','text',...
            'String', axisTitle,...
            'Units','Normalized',...
            'Parent',hFig,'Position', titlePos,...
            'BackgroundColor',hFig.Color);
    end

%% Insert Buttons
% Insert buttons to play, pause the videos.
    function insertButtons(hFig,hAxes,videoSrc,vidObj)

        % Play button with text Start/Pause/Continue
        uicontrol(hFig,'unit','pixel','style','pushbutton','string','Start',...
                'position',[10 10 75 25], 'tag','PBButton123','callback',...
                {@playCallback,videoSrc,vidObj,hAxes});  

        % Exit button with text Exit
        uicontrol(hFig,'unit','pixel','style','pushbutton','string','Exit',...
                'position',[100 10 50 25],'callback', ...
                {@exitCallback,videoSrc,hFig});
            
        % Tag button with text Tag
        uicontrol(hFig,'unit','pixel','style','pushbutton','string','Prev',...
                'position',[200 10 50 25],'callback', ...
                {@prevCallback,videoSrc,hAxes});
        
        % Next button with text Next    
        uicontrol(hFig,'unit','pixel','style','pushbutton','string','Next',...
                'position',[300 10 50 25],'callback', ...
                {@nextCallback,videoSrc,hAxes});
        
        % Tag button with text Tag
        uicontrol(hFig,'unit','pixel','style','pushbutton','string','Tag',...
                'position',[400 10 50 25],'callback', ...
                {@tagCallback});
    end     

%% Play Button Callback
% This callback function rotates input video frame and displays original
% input video frame and rotated frame on axes. The function
% |showFrameOnAxis| is responsible for displaying a frame of the video on
% user-defined axis. This function is defined in the file
% <matlab:edit(fullfile(matlabroot,'toolbox','vision','visiondemos','showFrameOnAxis.m')) showFrameOnAxis.m>
    function playCallback(hObject,~,videoSrc,vidObj,hAxes)
       try
            % Check the status of play button
            isTextStart = strcmp(hObject.String,'Start');
            isTextCont  = strcmp(hObject.String,'Continue');
            if isTextStart
               % Two cases: (1) starting first time, or (2) restarting 
               % Start from first frame
               if isDone(videoSrc)
                  reset(videoSrc);
               end
            end
            if (isTextStart || isTextCont)
                hObject.String = 'Pause';
            else
                hObject.String = 'Continue';
            end

            % Rotate input video frame and display original and rotated
            % frames on figure
            
                       
            while strcmp(hObject.String, 'Pause') && ~isDone(videoSrc)
                [frame,currentFrame] = getFrame(vidObj,currentFrame,1);
                % Get input video frame and rotated frame
                %[frame,rotatedImg,angle] = getAndProcessFrame(videoSrc,angle);                
                % Display input video frame on axis
                showFrameOnAxis(hAxes.axis1, frame);
                % Display rotated video frame on axis
                %showFrameOnAxis(hAxes.axis2, rotatedImg);

                set(mTextBox,'String',int2str(currentFrame));
                pos = mTextBox.Position;
                mTextBox.Position = [300 50 100 50];
            end

            % When video reaches the end of file, display "Start" on the
            % play button.
            if isDone(videoSrc)
               hObject.String = 'Start';
            end
       catch ME
           % Re-throw error message if it is not related to invalid handle 
           if ~strcmp(ME.identifier, 'MATLAB:class:InvalidHandle')
               rethrow(ME);
           end
       end
    end

%% Video Processing Algorithm
% This function defines the main algorithm that is invoked when play button
% is activated.
%{
    function [frame,rotatedImg,angle] = getAndProcessFrame(videoSrc,angle)
        
        % Read input video frame
        frame = step(videoSrc);
        
        % Pad and rotate input video frame
        paddedFrame = padarray(frame, [30 30], 0, 'both');
        rotatedImg  = imrotate(paddedFrame, angle, 'bilinear', 'crop');
        angle       = angle + 1;
    end
%}
%% Play Video
    function [showFrame,currentFrame] = getFrame(vidobj,currentFrame,backOrFore)
        currentFrame = currentFrame + backOrFore;
        showFrameTemp = imrotate(read(vidobj,currentFrame),-90);
        showFrame = imcrop(showFrameTemp,[0 0 1080 960]);
    end
        



%% Exit Button Callback
% This callback function releases system objects and closes figure window.
    function exitCallback(~,~,videoSrc,hFig)
        
        feature = myodatainput(data_dir,data_file,heademg,headgyro)
        if(length(feature(:,1))>length(labelArray))
%            for i= 1:8
               feature(length(labelArray)+1:end,:) = []
%            end        
        else
            labelArray(length(feature(:,1))+1:end) = []
        end
        output = cat(2,labelArray', feature)
        csvwrite([videoName 'feature.csv'], output);
        % Close the video file
        release(videoSrc); 
        % Close the figure window
        close(hFig);
    end
%% Next Button Cllback
    function nextCallback(hObject,~,videoSrc,hAxes)
        [frame,currentFrame] = getFrame(vidObj,currentFrame,1);
        showFrameOnAxis(hAxes.axis1, frame);
        set(mTextBox,'String',int2str(currentFrame));
        pos = mTextBox.Position;
        mTextBox.Position = [300 50 100 50];
    end
%% Prev Button Cllback
    function prevCallback(hObject,~,videoSrc,hAxes)
        [frame,currentFrame] = getFrame(vidObj,currentFrame,-2);
        showFrameOnAxis(hAxes.axis1, frame);
        set(mTextBox,'String',int2str(currentFrame));
        pos = mTextBox.Position;
        mTextBox.Position = [300 50 100 50];
    end
%% Next Button Callback
% This callback function releases system objects and closes figure window.
%{
    function nextCallback(hObject,~,videoSrc,hAxes)
        
        [frame,currentFrame] = getFrame(vidObj,currentFrame,1);
        %[frame,rotatedImg,angle] = getAndProcessFrame(videoSrc,angle);                
        % Display input video frame on axis
        showFrameOnAxis(hAxes.axis1, frame);
        % Display rotated video frame on axis
        showFrameOnAxis(hAxes.axis2, rotatedImg);

        set(mTextBox,'String',int2str(angle));
        pos = mTextBox.Position;
        mTextBox.Position = [300 50 100 50];
        prompt = {'輸入動作'};
        dlg_title = 'Input';
        num_lines = 1;
        defaultans = {'1'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        appendLabel(answer);
    end
%}
    function tagCallback(hObject,~)

        prompt = {'輸入動作'};
        dlg_title = 'Input';
        num_lines = 1;
        defaultans = {'1'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        class(str2num(cell2mat(answer)));
        appendLabel(int32(str2num(cell2mat(answer))));
    end

    function appendLabel(answer)
        duration = (currentFrame - prevFrame);
        labelThis = zeros(1,duration);
        for i = 1:duration
            labelThis(i) = answer;
        end
        %labelThis(:,:) = int(answer);
        if(answer ~= 99)
            labelArray = [labelArray labelThis]
        end
        prevFrame = currentFrame;
    end

displayEndOfDemoMessage(mfilename)



end