'''
Subject Type Classifier of Suture Training 
'''

from argparse import ArgumentParser
import os
import time
import numpy as np
from sklearn.naive_bayes import GaussianNB
from sklearn.neural_network import MLPClassifier
from sklearn.svm import SVC
from sklearn.model_selection import KFold
from sklearn.metrics import accuracy_score, f1_score
import xgboost as xgb
from sklearn.model_selection import train_test_split
import pandas as pd
import xlsxwriter


def main():
    ''' Main function '''
    parser = ArgumentParser(
        description='I want to publish a paper')
    parser.add_argument('--train', type=str, 
                        default='./myodoc_out_train', help='choose the trainig data')
    parser.add_argument('--test', type=str, 
                        default='./myodoc_out_test', help='choose the testing data')
    parser.add_argument('--feat', type=str, choices=['emg', 'emg+gyro', 'gyro', 'gyro+accel','all'],
                        default='all', help='choose type of modality')
    parser.add_argument('--clf', type=str, choices=['gnb', 'svm', 'xgb','mlp'],
                        default='xgb', help='choose type of classifier')
    parser.add_argument('--nor', type=str, choices=['one_one', 'mean', 'zero_one'],
                        default='zero_one', help='choose type of classifier')
    parser.add_argument('--deldefault', type=str, choices=['Y','N'],
                        default='N', help='remove default')
    parser.add_argument('--result', type=str,
        default='result', help='name of result file')
    args = parser.parse_args()

    ####################### read extracted data
    train_data = pd.read_csv(args.train+'.csv', header=None)

    train_labels = train_data[0]
    train_features = train_data.drop([0], axis=1)

    train_labels=np.array(train_labels)
    train_features=np.array(train_features)

########################################read test files#####################
    test_data = pd.read_csv(args.test+'.csv', header=None)

    test_labels = test_data[0]
    test_features = test_data.drop([0], axis=1)

    test_labels=np.array(test_labels)
    test_features=np.array(test_features)

########################################
    # setup classifier
    if args.clf == 'gnb':
        clf = GaussianNB()
    elif args.clf == 'mlp':
        clf = MLPClassifier(hidden_layer_sizes=(110,),#one layer 110 best 
            activation='relu', solver='adam', alpha=0.0001, 
            batch_size='auto', learning_rate='constant', 
            learning_rate_init=0.001, power_t=0.5,
            max_iter=200, shuffle=True, random_state=None, 
            tol=0.0001, verbose=False, warm_start=False, 
            momentum=0.9, nesterovs_momentum=True, early_stopping=False, 
            validation_fraction=0.1, beta_1=0.9, beta_2=0.999, epsilon=1e-08)
    elif args.clf == 'svm':
        clf = SVC(C=2, kernel='linear')#c=2,linear
        #‘linear’, ‘poly’, ‘rbf’, ‘sigmoid’, 
    elif args.clf == 'xgb':
        clf = xgb.XGBClassifier(
            max_depth=3,#best
            learning_rate=0.1,
            n_estimators=500,#best!!
            silent=True,
            objective="binary:logistic",
            nthread=-1,
            gamma=0,#best
            min_child_weight=3,#best
            max_delta_step=0,
            subsample=1,
            colsample_bytree=0.5,
            colsample_bylevel=0.5,
            reg_alpha=0,
            reg_lambda=1,
            scale_pos_weight=1,
            base_score=0.5,
            seed=0
        )
       

                #choose the type of features
    if args.feat == 'myo':
        train_features = train_features[:,[0,1,2,3,4,5,6,7]]
        test_features = test_features[:,[0,1,2,3,4,5,6,7]]
    elif args.feat == 'myo+gyro':
        train_features = train_features[:,[0,1,2,3,4,5,6,7,8,9,10,11]]  
        test_features = test_features[:,[0,1,2,3,4,5,6,7,8,9,10,11]]  
    elif args.feat == 'gyro':
        train_features = train_features[:,[8,9,10,11]]
        test_features = test_features[:,[8,9,10,11]]
    elif args.feat == 'gyro+accel':
        train_features = train_features[:,[8,9,10,11,12,13]]
        test_features = test_features[:,[8,9,10,11,12,13]]
        
        
###############################################QQQQQQQQQQQQQ##################
       

    if args.nor == 'mean':
        # normalize using mean and std
        train_features_mean = np.mean(train_features, axis=0)
        train_features_std = np.std(train_features, axis=0)
        train_features = (train_features - train_features_mean) / train_features_std
        test_features_mean = np.mean(test_features, axis=0)
        test_features_std = np.std(test_features, axis=0)
        test_features = (test_features - test_features_mean) / test_features_std
    elif args.nor == 'one_one':
        # map features to [-1, 1]
        train_features_max = np.max(train_features, axis=0)
        train_features_min = np.min(train_features, axis=0)
        train_features = (train_features - train_features_min) / (train_features_max - train_features_min)
        train_features = train_features * 2 - 1
        test_features_max = np.max(test_features, axis=0)
        test_features_min = np.min(test_features, axis=0)
        test_features = (test_features - test_features_min) / (test_features_max - test_features_min)
        test_features = test_features * 2 - 1
    elif args.nor == 'zero_one':
        # map features to [-1, 1]
        train_features_max = np.max(train_features, axis=0)
        train_features_min = np.min(train_features, axis=0)
        train_features = (train_features - train_features_min) / (train_features_max - train_features_min)
        
        test_features_max = np.max(test_features, axis=0)
        test_features_min = np.min(test_features, axis=0)
        test_features = (test_features - test_features_min) / (test_features_max - test_features_min)
        
#########################delete default class

    if args.deldefault == 'Y':
        train_labels0 = np.where(train_labels==1)
        train_labels0 = np.array(train_labels0)
        train_features = np.delete(train_features, train_labels0, axis=0)
        train_labels = np.delete(train_labels, train_labels0, axis=0)

        test_labels0 = np.where(test_labels==1)
        test_labels0=np.array(test_labels0)
        test_features = np.delete(test_features, test_labels0, axis=0)  
        test_labels = np.delete(test_labels, test_labels0, axis=0) 
        
        ################################################
    # fit classifier
    clf.fit(train_features, train_labels)

    # predict arousal and valence
    train_predict_labels = clf.predict(train_features)
    test_predict_labels = clf.predict(test_features)

    # metrics calculation (accuracy and f1 score)
    train_accuracy = accuracy_score(train_labels, train_predict_labels)
    train_f1score = f1_score(train_labels, train_predict_labels, average='macro')
    test_accuracy = accuracy_score(test_labels, test_predict_labels)
    test_f1score = f1_score(test_labels, test_predict_labels, average='macro')

   
    print('Training Result')
    print(" Accuracy: {}, F1score: {}".format(train_accuracy, train_f1score))

    print('Validating Result')
    print(" Accuracy: {}, F1score: {}".format(test_accuracy, test_f1score))

    workbook = xlsxwriter.Workbook(args.result+'.xlsx')
    worksheet = workbook.add_worksheet()
    worksheet.write(0,0,'golden')
    worksheet.write(0,1,'predict')
    worksheet.write(0,2,'timestep')
    for i in range(test_labels.shape[0]):
        worksheet.write(i+1,0,test_labels[i])
        worksheet.write(i+1,1,test_predict_labels[i])
        worksheet.write(i+1,2,i+1)
    workbook.close()

if __name__ == '__main__':

    main()
