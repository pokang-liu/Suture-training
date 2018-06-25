# Suture-Training
EMG signal processing methods and the machine learning model for prediction
## Requirement
matlab == 2015b+
Python == 3.6.3  
numpy == 1.13.3  
scipy == 0.19.1  
scikit-learn == 0.19.0  
xgboost == 0.6  
## background and motivation
In the medical ﬁeld, suture training is a compulsory course. Traditionally the medical students would use the artificial skin to practice suturing together in the lecture, and a surgeon would stand on stage, monitoring their performance and correct their postures and motions. However, it is impossible for a single surgeon to keep an eye on every student throughout the whole process, hence it would be time consuming and ineffective. Regarding this, we aim to establish a big database, utilize the technique of machine learning, and design Human Machine Interface (HCI) which could automatically analyze the motions and evaluate the performance of medical students when undergoing suture training. 
## Introduction
 ![](https://i.imgur.com/2NP8dGP.jpg)
This repository is used to establish the database for suture training. As shown in the blue blocks in the figure above, each file in this repository is one of the step among the overall processing flow. the data collected from wearable deivce, and  
The files in this repository can be divided into three parts:
-    myo_plothead:
mark the pulse in the signal to align the data and video


-    myo_data_input:
Processing the raw data from [MYO Armband](https://)

-    myo_GUI.m:
A graphic user interface used to label the data
-    rnn.py
A machine learning model used to predict the motion of the subject
-    myo_main.py
Machine learning models used to predict the subject type
## File discription
### myo_plothead.m
The idea is derived from the clapboard. We slap the EMG electrodes to make a large impulse before actual data collection. Hence, we could align the signal data with the video by this sign in the following functions. myo_plothead would mark the index of the large pulse in the EMG data.

- Input: EMG raw data
- Output: The index of the strong pulse

![](https://i.imgur.com/KeI3FDK.jpg)
### myo_data_input.m

preproessing the raw data(EMG*8, accelerometer*3)

-    ABS
-    Moving average
-    Resampling: change 200/sec sampling rate to 24/sec 

### myo_GUI.m
#### A graphic user interface used to label the data
-    Input:a data file(.csv) and a video file(.mp4)
-    Output: 18 features with labels(19 columns .csv)
- usage: 
    - change the video's name, data file's name and  the clapboard's starting point in the data file, then run the script.
    - label the clapboards's starting point in the video as 99
    - label the following motions(1: Holding, 2: Cutting, 3: Digging, 4: Pulling) 
- tips
    - press the ??? when you want to label
    -  type the label in the dialogue box and press enter
    - press exit in the end of the video  

### rnn.py
#### A keras-based Recurrent Neuron Network for four-class classifiaction
-    Input: data processed by myo_data_input and its corresponding labels (.csv files)
-    Output: four types of motion related to suturing: 
        -    Holding the needle
        -    Cutting the stitch
        -    Supinating the stitch
        -    Removing the stitch 
### myo_main.py
#### A scikit-learn based machine learning model combo for binary calssification
- input:
- output: subject type prediction 
    - 0: inexperienced subject
    - 1: experienced subject
- models 
    - Extreme Gradient Boosting
    - Support Vector Machine
    - Guassian Naive Bayes  
-  Usage
```
python myo_main.py --data [AMIGOS_DATA_DIRECTORY (default is ./data)]
               --feat [MODALITY_TYPE (default is all)]
               --clf [CLASSIFIER_TYPE (default is xgb)]
               --nor [NORMALIZATION_METHOD (default is no)]
```
