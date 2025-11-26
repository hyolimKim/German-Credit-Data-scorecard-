# 필요한 패키지 설치 및 로드
install.packages("ggplot2")
install.packages("ggthemes")
install.packages("dplyr")
install.packages("randomForest")
install.packages("caret")

library(ggplot2)
library(ggthemes)
library(dplyr)
library(randomForest)
library(caret)


# 데이터 불러오기
stroke<- read.csv("C:/Users/김효림/OneDrive/바탕 화면/쌀데이터/healthcare-dataset-stroke-data.csv", stringsAsFactors = FALSE)

# 데이터 구조 확인
str(stroke)

# 결측값 확인
cat("결측값 개수:\n")
colSums(is.na(stroke))



# train, test 데이터 분리 (80:20 비율)
set.seed(42)
train_indices <- sample(1:nrow(stroke), 0.8 * nrow(stroke))
train <- stroke[train_indices, ]
test <- stroke[-train_indices, ]

# 흡연 상태 변수 추가 전처리

train$SmokingGroup <- ifelse(train$smoking_status == "never smoked", "Non-smoker",
                             ifelse(train$smoking_status == "formerly smoked", "Ex-smoker", 
                                    "Current Smoker"))
test$SmokingGroup <- ifelse(test$smoking_status == "never smoked", "Non-smoker",
                            ifelse(test$smoking_status == "formerly smoked", "Ex-smoker", 
                                   "Current Smoker"))

# 흡연 상태 시각화
ggplot(train, aes(x = SmokingGroup, fill = factor(stroke))) +
  geom_bar(stat = 'count', position = 'dodge') +
  labs(x = 'Smoking Group', y = 'Count', fill = 'Stroke') +
  theme_few()

# 나이 그룹 변수 생성
train$AgeGroup <- cut(train$age, breaks = c(0, 18, 60, 100), 
                      labels = c("Young", "Middle-aged", "Senior"))
test$AgeGroup <- cut(test$age, breaks = c(0, 18, 60, 100), 
                     labels = c("Young", "Middle-aged", "Senior"))

# 나이와 stroke
stroke$AgeGroup <- cut(stroke$age, breaks = c(0, 30, 50, 100), 
                            labels = c("Young", "Middle-aged", "Elderly"))
mosaicplot(~ stroke + AgeGroup, data = stroke, color = TRUE, main = "Stroke vs Age Group")


# 성별과 나이별 뇌졸중 발생 시각화
ggplot(stroke, aes(x = age, fill = factor(stroke))) +
  geom_histogram(binwidth = 5, position = "dodge") +
  facet_wrap(~ gender) +
  labs(
    title = "Age Distribution and Stroke by Gender",
    x = "Age",
    y = "Count",
    fill = "Stroke"
  ) +
  theme_minimal()


# 비만 여부 변수 생성
train$Obesity <- ifelse(train$bmi > 30, "Obese", "Not Obese")
test$Obesity <- ifelse(test$bmi > 30, "Obese", "Not Obese")

# 변수 Factor로 변환
factor_vars <- c('gender', 'ever_married', 'work_type', 'Residence_type', 
                 'smoking_status', 'stroke', 'AgeGroup', 'SmokingGroup', 'Obesity')
train[factor_vars] <- lapply(train[factor_vars], as.factor)
test[factor_vars] <- lapply(test[factor_vars], as.factor)

# 데이터 스케일링 (연속형 변수)
train_scaled <- train
test_scaled <- test
train_scaled$age <- scale(train$age)
train_scaled$bmi <- scale(train$bmi)
train_scaled$avg_glucose_level <- scale(train$avg_glucose_level)

test_scaled$age <- scale(test$age)
test_scaled$bmi <- scale(test$bmi)
test_scaled$avg_glucose_level <- scale(test$avg_glucose_level)


# 랜덤 포레스트 모델 생성
set.seed(754)
rf_model <- randomForest(factor(stroke) ~ age + hypertension + heart_disease + 
                           avg_glucose_level + bmi + gender + work_type +
                           Residence_type + smoking_status + AgeGroup +
                           SmokingGroup + Obesity, 
                         data = train)

# 오류율 확인
rf_model$err.rate

# 최대 오류율 확인
max_error <- max(rf_model$err.rate)
print(max_error)


#######
# 하이퍼파라미터 튜닝을 위한 교차 검증 설정
train_control <- trainControl(method = "cv", number = 10) # 10-fold 교차 검증

# 하이퍼파라미터 튜닝을 위한 그리드 설정
tune_grid <- expand.grid(mtry = c(1:5)) # mtry를 1부터 5까지 실험

# 랜덤 포레스트 모델 생성
set.seed(754)
rf_model_cv <- train(factor(stroke) ~ age + hypertension + heart_disease + 
                       avg_glucose_level + bmi + gender + work_type +
                       Residence_type + smoking_status + AgeGroup +
                       SmokingGroup + Obesity, 
                     data = train,
                     method = "rf", 
                     trControl = train_control,
                     tuneGrid = tune_grid)

rf_model_cv$err.rate

# 최대 오류율 확인
max_error <- max(rf_model$err.rate)
print(max_error)

# 모델 오류율 및 성능 확인
print(rf_model_cv$results)
predictions <- predict(rf_model_cv, newdata = test)
confusion_matrix <- confusionMatrix(predictions, test$stroke)

# 혼동 행렬 및 정확도 출력
print(confusion_matrix)

##
# 모델 오류 수정
train_control <- trainControl(method = "cv", number = 10)

# 모델 학습
rf_model_cv <- train(factor(stroke) ~ age + hypertension + heart_disease + 
                       avg_glucose_level + bmi + gender + work_type +
                       Residence_type + smoking_status + AgeGroup +
                       SmokingGroup + Obesity, 
                     data = train,
                     method = "rf", 
                     trControl = train_control)

# 오류율 확인
rf_model_cv$err.rate
print(rf_model_cv$err.rate)

##

# 모델 정확도 시각화
plot(rf_model, ylim = c(0, 1))
legend('topright', colnames(rf_model$err.rate), col = 1:3, fill = 1:3)


# 변수 중요도 시각화
importance <- importance(rf_model)
varImportance <- data.frame(Variables = row.names(importance), 
                            Importance = round(importance[ ,'MeanDecreaseGini'], 2))

# 변수 중요도 시각화
library(ggthemes)
ggplot(varImportance, aes(x = reorder(Variables, Importance), y = Importance, fill = Importance)) +
  geom_bar(stat = 'identity') + 
  labs(x = 'Variables', y = 'Importance') +
  coord_flip() +
  theme_few()



# 테스트 데이터 예측 및 결과 저장
predictions <- predict(rf_model, test)
solution <- data.frame(id = test$id, stroke = predictions)
write.csv(solution, file = 'stroke_predictions.csv', row.names = FALSE)



######## rf 모델 오류 검정 
# caret 패키지로 교차 검증
install.packages("caret")
library(caret)

# 교차 검증 설정
train_control <- trainControl(method = "cv", number = 10)

# 모델 학습
rf_model_cv <- train(factor(stroke) ~ age + hypertension + heart_disease + 
                       avg_glucose_level + bmi + gender + work_type +
                       Residence_type + smoking_status + AgeGroup +
                       SmokingGroup + Obesity, 
                     data = train,
                     method = "rf", 
                     trControl = train_control)

# 오류율 확인
rf_model_cv$err.rate

# 최대 오류율 확인
max_error <- max(rf_model_cv$err.rate)
print(max_error)


# 모델 정확도 시각화
plot(rf_model, ylim = c(0, 1))

legend('topright', colnames(rf_model$err.rate), col = 1:3, fill = 1:3)

#Scorecard용 데이터 
train_sc <- train %>% mutate_if(is.factor, as.character)
test_sc  <- test  %>% mutate_if(is.factor, as.character)

# stroke 타겟  numeric으로 변환 
train_sc$stroke <- as.numeric(train_sc$stroke)
test_sc$stroke  <- as.numeric(test_sc$stroke)

# 변수 binning (IV 기반 자동 bin 분할)
bins <- woebin(train_sc, y = "stroke")

#WOE 변환
train_woe <- woebin_ply(train_sc, bins)
test_woe  <- woebin_ply(test_sc, bins)

#로지스틱 회귀 기반 Scorecard 모델
scorecard_model <- glm(stroke ~ ., data = train_woe, family = binomial)
summary(scorecard_model)


#Scorecard 생성
card <- scorecard(
  bins = bins,
  model = scorecard_model,
  points0 = 600,   # baseline score
  odds0 = 1/20,    # baseline odds
  pdo = 50         # points to double odds
)

card

#데이터별 Score 계산
train_score <- scorecard_ply(train_sc, card)
test_score  <- scorecard_ply(test_sc,  card)

head(test_score)

#Score 기반 ROC-AUC 확인
library(pROC)
roc_score <- roc(test$stroke, test_score$score)
auc(roc_score)
plot(roc_score, col = "blue", main = "Scorecard ROC Curve")

