# Suture-Training
signal processing methods of EMG and the model for prediction
## Requirement

Python == 3.6.3  
biosppy == 0.5.0  
EMD-signal == 0.2.3  
numpy == 1.13.3  
scipy == 0.19.1  
scikit-learn == 0.19.0  
xgboost == 0.6  
## Usage

-    123
-    preprocessing the signal
```
plothead.m
```
-    Training and Cross Validation
```
python main.py --data [AMIGOS_DATA_DIRECTORY (default is ./data)]
               --feat [MODALITY_TYPE (default is all)]
               --clf [CLASSIFIER_TYPE (default is xgb)]
               --nor [NORMALIZATION_METHOD (default is no)]
```
