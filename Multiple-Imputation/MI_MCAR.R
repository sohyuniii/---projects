library(readr)
library(ggplot2)
library(caret)
library(DMwR)
library(mice)
library(missForest)
df <- read_csv("transfusion.csv")
colnames(df) <- c('x1','x2','x3','x4','y')
set.seed(1234) ; df$x2 <- rpois(748,20)
df <- df %>% arrange(y)
df <- df[c(300:748),] ; n <- 449

### NA - MCAR & data split ###
a1 <- 0 ; a2 <- 0
set.seed(1234)
z <- rnorm(n,-0.5,1)
U1 <- a1*x3 + a2*scale(y) + z
df$x3_na <- ifelse(U1>0,NA,x3)

set.seed(0804)
z <- rnorm(n,-0.5,1)
U2 <- a1*x4 + a2*scale(y) + z
df$x4_na <- ifelse(U2>0,NA,x4)

colSums(is.na(df)) # 28% 33% -> 15.5%

intrain <- createDataPartition(y=df$y, p=0.7, list=FALSE) 
train <- df[intrain, ] ; test <- df[-intrain, ]
colSums(is.na(train)) ; colSums(is.na(test))

write.csv(train,'train_MCAR.csv')
write.csv(test,'test_MCAR.csv')

train <- read.csv('train_MCAR.csv') ; train <- train[,-1]
test <- read.csv('test_MCAR.csv') ; test <- test[,-1]

### 0. Evaluation criteria

rmse <- function(train,test){
  train <- as.data.frame(scale(train))
  test <- as.data.frame(scale(test))
  
  sqrt(sum((train$x3-train$x3_imput)^2)/92) + 
    sqrt(sum((train$x4-train$x4_imput)^2)/102) +
    sqrt(sum((test$x3-test$x3_imput)^2)/37) + 
    sqrt(sum((test$x4-test$x4_imput)^2)/48)
}

UCE <- function(train,test){
  myglm <- glm(y ~ x1+x2+x3_imput+x4_imput, data = train, family = "binomial")
  prob <- predict(myglm,newdata = test[,c('x1','x2','x3_imput','x4_imput')],type ="response")
  pred <- rep(0,134) ; pred[prob >.5]=1
  mean(pred!= test$y)
}

### 1. Mean
df1 <- df
train1 <- df[intrain, ] ; test1 <- df[-intrain, ]

# 1) train -> test
train1$x3_imput <- ifelse(is.na(train1$x3_na), mean(train1$x3_na, na.rm = T), train1$x3_na)
train1$x4_imput <- ifelse(is.na(train1$x4_na), mean(train1$x4_na, na.rm = T), train1$x4_na) 
test1$x3_imput <- ifelse(is.na(test1$x3_na), mean(train1$x3_na, na.rm = T), test1$x3_na)
test1$x4_imput <- ifelse(is.na(test1$x4_na), mean(train1$x4_na, na.rm = T), test1$x4_na)
rmse(train1,test1)
UCE(train1,test1)

# 2) train + test
train1$x3_imput <- ifelse(is.na(train1$x3_na), mean(df1$x3_na, na.rm = T), train1$x3_na)
train1$x4_imput <- ifelse(is.na(train1$x4_na), mean(df1$x4_na, na.rm = T), train1$x4_na) 
test1$x3_imput <- ifelse(is.na(test1$x3_na), mean(df1$x3_na, na.rm = T), test1$x3_na)
test1$x4_imput <- ifelse(is.na(test1$x4_na), mean(df1$x4_na, na.rm = T), test1$x4_na)
rmse(train1,test1)
UCE(train1,test1)

### 2. KNN
df2 <- df
train2 <- df[intrain, ] ; test2 <- df[-intrain, ]

# 1) train -> test
train_new <- as.data.frame(train2[,c(1,2,6,7)])
train_knn <- knnImputation(train_new) ; colnames(train_knn) <- c('x1','x2','x3_imput','x4_imput')
train_knn <- cbind(train_knn,train2[,c(3,4,5)])
test_new <- as.data.frame(test2[,c(1,2,6,7)])
test_knn <- knnImputation(test_new) ; colnames(test_knn) <- c('x1','x2','x3_imput','x4_imput')
test_knn <- cbind(test_knn,test2[,c(3,4,5)])
rmse(train_knn,test_knn)
UCE(train_knn,test_knn)

# 2) train + test
df_new <- as.data.frame(rbind(train[,c(1,2,6,7)],test[,c(1,2,6,7)]))
df_knn <- knnImputation(df_new) ; colnames(df_knn) <- c('x1','x2','x3_imput','x4_imput')
train_knn <- cbind(df_knn[1:315,],train2[,c(3,4,5)])
test_knn <- cbind(df_knn[316:449,],test2[,c(3,4,5)])
rmse(train_knn,test_knn)
UCE(train_knn,test_knn)

### 3. MICE
# 1) train -> test
train_mice <- mice(train[,c(1,2,6,7)])
train_mice <- complete(train_mice) ; colnames(train_mice) <- c("x1","x2",'x3_imput','x4_imput')
train_mice <- cbind(train_mice[,c(3,4)],train[,1:5])

test_mice <- mice(test[,c(1,2,6,7)])
test_mice <- complete(test_mice) ; colnames(test_mice) <- c("x1","x2",'x3_imput','x4_imput')
test_mice <- cbind(test_mice[,c(3,4)],test[,1:5])

rmse(train_mice,test_mice)
UCE(train_mice,test_mice)

# 2) train + test
df_mice <- mice(df_new) 
df_mice <- complete(df_mice) ; colnames(df_mice) <- c('x1','x2','x3_imput','x4_imput')
train_mice <- cbind(df_mice[1:315,],train[,c(3,4,5)])
test_mice <- cbind(df_mice[316:449,],test[,c(3,4,5)])
rmse(train_mice,test_mice)
UCE(train_mice,test_mice)

### 4. MissForest
df4 <- df
train4 <- df[intrain, ] ; test4 <- df[-intrain, ]

# 1) train -> test
train_new <- as.data.frame(train[,c(1,2,6,7)])
train_miss <- missForest(train_new) ; train_miss <- train_miss$ximp
colnames(train_miss) <- c('x1','x2','x3_imput','x4_imput')
train_miss <- cbind(train_miss,train[,c(3,4,5)])

test_new <- as.data.frame(test[,c(1,2,6,7)])
test_miss <- missForest(test_new) ; test_miss <- test_miss$ximp
colnames(test_miss) <- c('x1','x2','x3_imput','x4_imput')
test_miss <- cbind(test_miss,test[,c(3,4,5)])

rmse(train_miss,test_miss)
UCE(train_miss,test_miss)

# 2) train + test
df_new <- as.data.frame(rbind(train[,c(1,2,6,7)],test[,c(1,2,6,7)]))
df_miss <- missForest(df_new) ; df_miss <- df_miss$ximp
colnames(df_miss) <- c('x1','x2','x3_imput','x4_imput')
train_miss <- cbind(df_miss[1:315,],train[,c(3,4,5)])
test_miss <- cbind(df_miss[316:449,],test[,c(3,4,5)])
rmse(train_miss,test_miss)
UCE(train_miss,test_miss)