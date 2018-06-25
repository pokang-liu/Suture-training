function [output] = myodatainput(directory,file_name,heademg,headgyro)
rawdata_list = {'emg','gyro','orientation','accelerometer','orientationEuler'}
%%%%%%%% parameters %%%%%%%%%%%%%%%%%%%%%%%%
EMG_MAV = 20;
GYRO_MAV = 40;
ORIENT_MAV = 40;
%%%%%%%% read_five_data %%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(rawdata_list)
   % dir = ['trial_MYO/' rawdata_list{i} '-' file_name];
    dir = [directory rawdata_list{i} '-' file_name];
    file = importdata(dir);
    if strcmp(rawdata_list{i}, 'emg')
        EMG = file.data(:,2:9);
    elseif strcmp(rawdata_list{i}, 'gyro')
        GYRO = file.data(:,2:4);
    elseif strcmp(rawdata_list{i}, 'orientation')
        ORIENT = file.data(:,2:4);
    end
    
end
%%%%%%%%%%EMG  
%if strcmp(rawdata_list{i}, 'emg')
    %abs
    EMG_MAV
    EMG = abs(EMG);
    figure(1);
    plot([1:length(EMG(:,1))],EMG(:,1)', '.-'); axis tight; ylabel('signal'); legend('1');
    B = 1/EMG_MAV*ones(EMG_MAV,1);
    EMG = filter(B,1,EMG);
  
    EMG(1:heademg,:)=[];
    figure(2);
    plot([1:length(EMG(:,1))],EMG(:,1)', '.-'); axis tight; ylabel('signal'); legend('1');
        %interpolate
    len=length(EMG(:,1));
    x1 = 1:1:len;
    x2 = 1:1/24:len;
    for i = 1:8
        IN_EMG(:,i) = interp1(x1,EMG(:,i),x2);
    end
   

        %down downsample
    for i = 1:8
        DOWN_EMG(:,i)= downsample(IN_EMG(:,i),200,100);
    end




%elseif strcmp(rawdata_list{i}, 'gyro')
    GYRO = abs(GYRO)

    B = 1/GYRO_MAV*ones(GYRO_MAV,1);
    GYRO = filter(B,1,GYRO);
    GYRO(1:headgyro,:)=[];
    
    
        %interpolate
    len=length(GYRO(:,1));
    x1 = 1:1:len;
    x2 = 1:1/24:len;
    for i = 1:3
        IN_GYRO(:,i) = interp1(x1,GYRO(:,i),x2);
    end
   
        %down downsample
    for i = 1:3
        DOWN_GYRO(:,i)= downsample(IN_GYRO(:,i),50,25);
    end




%elseif strcmp(rawdata_list{i}, 'orientation')
    print('orientation')
    ORIENT = abs(ORIENT)

    B = 1/ORIENT_MAV*ones(ORIENT_MAV,1);
    ORIENT = filter(B,1,ORIENT);
    ORIENT(1:headgyro,:)=[];
    
    
        %interpolate
    len=length(ORIENT(:,1));
    x1 = 1:1:len;
    x2 = 1:1/24:len;
    for i = 1:3
        IN_ORIENT(:,i) = interp1(x1,ORIENT(:,i),x2);
    end
  
        %down downsample
    for i = 1:3
        DOWN_ORIENT(:,i)= downsample(IN_ORIENT(:,i),50,25);
    end

 
%end
if length(DOWN_EMG(:,1))>length(DOWN_GYRO(:,1));
    min_length = length(DOWN_GYRO(:,1));
else
    min_length = length(DOWN_EMG(:,1));
end



DOWN_EMG =DOWN_EMG(1:min_length,:);
DOWN_GYRO =DOWN_GYRO(1:min_length,:);
DOWN_ORIENT =DOWN_ORIENT(1:min_length,:);
figure(3);
plot([1:length(DOWN_EMG(:,1))],DOWN_EMG(:,1)', '.-'); axis tight; ylabel('signal'); legend('1');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%plot head here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
features= cat(2,DOWN_EMG,DOWN_GYRO);
features= cat(2,features,DOWN_ORIENT);
output = [features];
%%%%%%%%%%%%%%%%%%%%%%dimension not consistence!!!!!!!!!!!!!!!!!!!!!!!!!
%%%%%%%%%%%%%%%%%%%%%%fuck!!!!!!!!!!!

%output = [DOWN_EMG(:,1); DOWN_EMG(:,2); DOWN_EMG(:,3); DOWN_EMG(:,4); DOWN_EMG(:,5); DOWN_EMG(:,6); DOWN_EMG(:,7); DOWN_EMG(:,8);];
%end

 