### Data description 
- 최종적인 목표는 urine의 cell free DNA에서 얻은 CNV 정보를 이용해서 암을 진단
- train : public big data인 TCGA dataset을 이용
- validation : urine data (but! urine sample을 많이 얻기가 어려운 부분이 있고 (시간적 물리적 비용) 또 소변 데이터는 quality가 떨어짐)

### Modeling (binary / 4 Class / 26 Class)
#### 1. K100, K50 데이터 Classification으로 암의 패턴 파악
#### 2. TCGA 5-fold cross-validation mean accuracy 측정
- scale, robust_scale, minmax_scale, maxabs_scale 을 이용하여 accuracy 비교
- logistic, SVM, random forest, AdaBoost, GBM, LightGBM, XGBoost 모델 비교
#### 3. TCGA로 모델 fitting -> 소변 데이터로 test

### 한계
- TCGA dataset은 조직 (암조직)에서 genomic data를 얻은 것
- CNV data를 생산하는 방법도 다르고 (TCGA에서는 SNParray를 이용했고, urine data는 shallow whole genome sequencing을 이용, 비용절감 위해)
- 데이터 형태도 다르구요. (데이터 형태 통일을 위해 cytoband matching)
-> 방광암의 성능이 비교적 좋아서, 방광암에 초점

### Refernce
- [Chen and Guestrin. XGBoost: A scalable tree boosting system](https://dl.acm.org/citation.cfm?id=2939785)
- [Gradient Boosting Decision trees: XGBoost vs LightGBM (and catboost)](https://medium.com/kaggle-nyc/gradient-boosting-decision-trees-xgboost-vs-lightgbm-and-catboost-72df6979e0bb)
