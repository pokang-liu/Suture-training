
clc;
clear;
rawdata_list = {'emg','gyro','orientation','accelerometer','orientationEuler'}
%%%%%%%%%%%%%%%%%%%%%%%%%%%modify here!!!!!!!!!!!!!!!!%%%%%%%%%%%%%
file_name = '15.csv'
%%%%%%%% parameters %%%%%%%%%%%%%%%%%%%%%%%%
EMG_MAV = 20;
GYRO_MAV = 40;
ORIENT_MAV = 40

%%%%%%%% read_five_data %%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(rawdata_list)
   % dir = ['trial_MYO/' rawdata_list{i} '-' file_name];
    dir = ['P:\Desktop\³¢¬f§D\20180417\data\p\' rawdata_list{i} '-' file_name];
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

    B = 1/EMG_MAV*ones(EMG_MAV,1);
    EMG = filter(B,1,EMG);
  

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
    ORIENT = abs(ORIENT)

    B = 1/ORIENT_MAV*ones(ORIENT_MAV,1);
    ORIENT = filter(B,1,ORIENT);
  
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%plot head here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);
 plot([1:length(EMG(:,1))],EMG(:,1)', '.-'); axis tight; ylabel('signal'); legend('1');
 figure(2);
 plot([1:length(GYRO(:,1))],GYRO(:,1)', '.-'); axis tight; ylabel('signal'); legend('1');
 figure(3);
 plot([1:length(EMG(:,1))],EMG(:,2)', '.-'); axis tight; ylabel('signal'); legend('1');
 figure(4);
 plot([1:length(EMG(:,1))],EMG(:,3)', '.-'); axis tight; ylabel('signal'); legend('1');
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


