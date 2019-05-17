### 데이터 설명
- TCGA barcode : the primary identifier to distinguish biospecimen data
- Cytoband : band pattern formed on the chromosomes of cells undergoing a medium term <br>(the best time to examine the number of chromosomes , has a total of 862 information)

### Modeling (binary / 4 Class / 26 Class)
#### 1. K100, K50 데이터 Classification으로 암의 패턴 파악
#### 2. TCGA 5-fold cross-validation mean accuracy 측정
- scale, robust_scale, minmax_scale, maxabs_scale 을 이용하여 accuracy 비교
- logistic, SVM, random forest, AdaBoost, GBM, LightGBM, XGBoost 모델 비교
#### 3. TCGA로 모델 fitting -> 소변 데이터로 test

### Refernce
- [Chen and Guestrin. XGBoost: A scalable tree boosting system](https://dl.acm.org/citation.cfm?id=2939785)
- [Gradient Boosting Decision trees: XGBoost vs LightGBM (and catboost)](https://medium.com/kaggle-nyc/gradient-boosting-decision-trees-xgboost-vs-lightgbm-and-catboost-72df6979e0bb)
