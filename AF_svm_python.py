from mat4py import loadmat
from matplotlib import pyplot as plt
import scipy
from sklearn import svm
from sklearn import metrics
import numpy as np
import pandas as pd
import csv
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import roc_auc_score
from sklearn.metrics import RocCurveDisplay 


def extractFloatsFromRow(ToConvertString):
    return [float(x) for x in ToConvertString.split(',')]

def importFeatures(filename):
    feats = []
    with open(filename, newline='') as csvfile: #'mat_feats_table.csv' 
        csvreader =csv.reader(csvfile, delimiter=' ', quotechar='|')
        for row in csvreader:
            feats.append(extractFloatsFromRow(row[0]))
    feats = np.array(feats) # converts to numbers instead of strings
    return feats

def importLabels(filename):
    labels = []
    with open(filename, newline='') as csvfile: #'mat_labels.csv'
        csvreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
        for row in csvreader:
            labels.append(row[0])
    labels = np.array(labels, dtype=int) # converts to numbers instead of strings
    return labels


features2 = scipy.io.loadmat('mat_feats.mat', mat_dtype = True)
train_labels = scipy.io.loadmat('mat_labels.mat', mat_dtype = True)
# features = pd.read_csv('mat_feats_table.csv')
train_feats = importFeatures('mat_feats_table.csv') #training data
train_labels = importLabels('mat_labels.csv') #training data



# print(features)
# print(features(0,0))
# print(labels)
clf = svm.SVC(kernel='rbf')

clf.fit(train_feats, train_labels)

test_feats = importFeatures('mat_test_feats_table.csv')
test_labels = importLabels('mat_test_labels.csv')
# test_labels = np.array(test_labels, dtype=int)
# test_feats = np.array(test_feats)

detector_pred = clf.predict(test_feats) #X_test

# Prints provided from Marek
print(clf.kernel + " Number of mislabeled points out of a total %d points : %d" % (len(test_feats), (test_labels != detector_pred).sum()))

VECDIM = clf.n_features_in_
supportShape = clf.support_vectors_.shape

nbSupportVectors=supportShape[0]
vectorDimensions=supportShape[1]

print("nbSupportVectors = %d" % nbSupportVectors)
print("vectorDimensions = %d" % vectorDimensions)
print("degree = %d" % clf.degree)
print("coef0 = %f" % clf.coef0)
print("gamma = %f" % clf._gamma)
'''
A low C makes the decision surface smooth, 
while a high C aims at classifying all training examples correctly. 
gamma defines how much influence a single training example has. 
The larger gamma is, the closer other examples must be to be affected.
'''

print("Accuracy:", metrics.accuracy_score(test_labels, detector_pred))

# Confusion matrix for performance
cm = metrics.confusion_matrix(test_labels, detector_pred)
print("Confusion matrix:", cm) # displays as matrix variable
metrics.ConfusionMatrixDisplay.from_predictions(test_labels, detector_pred, display_labels=['Negative', 'Positive']) # plotted confusion matrix
sensitivity = cm[1, 1] / (cm[1,1] + cm[1,0]) # TP / (TP + FN)
specificity = cm[0, 0] / (cm[0, 0] + cm[0,1]) # TN / (TN + FP)
print('Sensitivity: ', sensitivity)
print('Specificity: ', specificity)
plt.show()



# ROC, also for performance
clf2 = LogisticRegression(solver="liblinear").fit(train_feats, train_labels)
detector_pred_prob = clf2.predict_proba(test_feats)[:, 1] # y_score
# print('y: ', np.size(test_labels))
# print('y_score: ', np.size(detector_pred_prob))
print("ROC_AUC_SCORE:", metrics.roc_auc_score(test_labels, detector_pred_prob)) # score instead of pred
# print('y: ', test_labels)

print('test_labels: ', sum(test_labels))

RocCurveDisplay.from_predictions(test_labels, detector_pred_prob, pos_label=1, )
plt.show()