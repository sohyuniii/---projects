### 데이터 설명
- TCGA barcode : the primary identifier to distinguish biospecimen data
- Cytoband : band pattern formed on the chromosomes of cells undergoing a medium term <br>(the best time to examine the number of chromosomes , has a total of 862 information)

### Modeling
#### 1. K100, K50 데이터 Classification으로 암의 패턴 파악
#### 2. TCGA 5-fold cross-validation mean accuracy 측정
- scale, robust_scale, minmax_scale, maxabs_scale 을 이용하여 accuracy 비교
- logistic, SVM, random forest, AdaBoost, GBM, LightGBM, XGBoost 
#### 3. TCGA로 모델 fitting -> 소변 데이터로 test
