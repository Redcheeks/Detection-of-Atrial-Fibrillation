from matplotlib import pyplot as plt
from sklearn import svm
from sklearn import metrics
from sklearn.linear_model import LogisticRegression
# from sklearn.metrics import roc_auc_score
# from sklearn.metrics import RocCurveDisplay 
from sklearn import metrics
import numpy as np
import csv



def extractFloatsFromRow(ToConvertString):
    return [float(x) for x in ToConvertString.split(',')]

def importFeatures(filename):
    feats = []
    with open(filename, newline='') as csvfile: #e.g: 'mat_feats_table.csv' 
        csvreader =csv.reader(csvfile, delimiter=' ', quotechar='|')
        for row in csvreader:
            feats.append(extractFloatsFromRow(row[0]))
    feats = np.array(feats) # converts to numbers instead of strings
    return feats

def importLabels(filename):
    labels = []
    with open(filename, newline='') as csvfile: #e.g: 'mat_labels.csv'
        csvreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
        for row in csvreader:
            labels.append(row[0])
    labels = np.array(labels, dtype=int) # converts to numbers instead of strings
    return labels

# Data import/load the files
train_feats = importFeatures('mat_feats_table.csv') #training data
train_labels = importLabels('mat_labels.csv') #training data
test_feats = importFeatures('mat_test_feats_table.csv') #test data
test_labels = importLabels('mat_test_labels.csv') #test data

clf = svm.SVC(kernel='rbf')
clf.fit(train_feats, train_labels)

detector_pred = clf.predict(test_feats) #X_test

# Prints provided from Marek, some parameters for sklearn
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
plot1 = metrics.ConfusionMatrixDisplay.from_predictions(test_labels, detector_pred, display_labels=['Negative', 'Positive']) # plotted confusion matrix, negative = 0 & positive = 1
sensitivity = cm[1, 1] / (cm[1,1] + cm[1,0]) # TP / (TP + FN)
specificity = cm[0, 0] / (cm[0, 0] + cm[0,1]) # TN / (TN + FP)
print('Sensitivity: ', sensitivity)
print('Specificity: ', specificity)

# ROC, also for performance
clf2 = LogisticRegression(solver="liblinear").fit(train_feats, train_labels)
detector_pred_prob = clf2.predict_proba(test_feats)[:, 1] # y_score
print("ROC_AUC_SCORE:", metrics.roc_auc_score(test_labels, detector_pred_prob)) # score instead of pred
plot2 = metrics.RocCurveDisplay.from_predictions(test_labels, detector_pred_prob, pos_label=1, )
plt.show()
