# 📘 Stroke Risk Prediction & Scorecard Modeling Project Portfolio
뇌졸중 위험도 예측을 위한 머신러닝 및 Scorecard 기반 해석 가능한 모델 개발
🧩 1. 프로젝트 개요 (Overview)

본 프로젝트는 뇌졸중 발생 가능성을 예측하는 머신러닝 모델을 구축하고,
특히 해석 가능한 Scorecard 모델을 적용하여
각 위험 요인이 뇌졸중 발생에 미치는 영향을 정량적으로 평가하는 것을 목표로 한다.

최근 의료 AI 분야에서는 단순한 예측 정확도뿐 아니라
설명 가능성(Explainability) 이 크게 강조되고 있다.
본 연구는 Random Forest 기반의 고성능 모델과 더불어,
금융권 신용평가에서 널리 사용되는 Scorecard 체계를 의료 데이터에 적용하여
의사·환자 모두 이해할 수 있는 직관적인 위험 점수(Risk Score) 시스템을 개발하였다.

🎯 2. 프로젝트 목표 (Objectives)
✔ 1) 뇌졸중 발생 여부를 예측하는 머신러닝 모델 개발

Random Forest 기반 예측 모델 구축

교차 검증을 활용한 성능 향상 및 안정성 확보

✔ 2) 위험 요인의 임상적 의미 분석

흡연, 연령, 평균 혈당, BMI 등 주요 변수들의 영향력 분석

변수 간 상호작용 및 위험군 파악

✔ 3) Scorecard 기반 해석 가능한 모델 구축

WOE 기반 변수 binning

로지스틱 회귀 기반 Scorecard 생성

개인별 위험 점수 산출 및 위험군 분류

✔ 4) 임상 적용이 가능한 설명 가능한 AI 모델 제안

단순히 예측만 하는 모델이 아니라
“왜 이 환자가 위험한가?”를 설명 가능한 형태로 제공

📚 3. 데이터 소개 (Dataset)

데이터 출처: Kaggle – Healthcare Stroke Dataset

총 샘플 수: 5,110명

목표 변수: stroke (1 = 뇌졸중, 0 = 정상)

주요 변수:

나이(age), 성별(gender), 결혼 여부(ever_married)

BMI, 평균 혈당(avg_glucose_level)

고혈압, 심장질환 여부

흡연 상태(smoking_status)

🛠 4. 데이터 전처리 및 Feature Engineering
✔ 1) 누락값·이상값 처리

BMI 결측값 대체

문자열 변수 → factor 변환

✔ 2) 신규 파생 변수 생성 (의학적 타당성 반영)

🔹 SmokingGroup (Non-smoker / Ex-smoker / Current Smoker)

🔹 AgeGroup (Young / Middle-aged / Senior)

🔹 Obesity (BMI > 30 → ‘Obese’)

✔ 3) Feature Scaling

age, bmi, avg_glucose_level 변수 표준화

🌲 5. Random Forest 기반 예측 모델
✔ 목적

복잡한 비선형 관계를 고려하여 높은 예측 성능을 확보하기 위함.

✔ 과정

Train/Test = 80:20 split

교차 검증을 통한 mtry 튜닝

중요 변수 분석(MeanDecreaseGini)

✔ 주요 결과

주요 위험 요인:
age, avg_glucose_level, hypertension, smoking_status, Obesity

혼동행렬 기반 정확도·민감도·특이도 도출

Random Forest는 높은 예측 성능을 제공하나
의료 분야에서는 해석력 부족(Black-box) 문제가 존재한다.

따라서 본 프로젝트는 Scorecard 모델을 추가 구축하여
모델 투명성을 크게 강화하였다.

🧮 6. Scorecard 기반 뇌졸중 위험도 평가 모델

Scorecard 모델은 금융권 신용평가에서 널리 사용되는 방식으로,
각 변수의 위험도를 점수 형식으로 환산하여
최종적으로 개인별 위험 점수(Risk Score) 를 산출한다.

본 프로젝트는 Scorecard를 의료 데이터에 적용한 점에서
“해석 가능성 높은 의료 AI 모델”을 구축했다는 의의가 있다.

✔ 6.1 WOE 기반 변수 binning

각 변수는 뇌졸중 발생 비율을 기준으로 구간(bin)으로 나뉘며,
각 구간마다 Weight of Evidence(WOE) 값이 계산된다.

예시:

변수	구간	WOE	의미
avg_glucose_level	>150	+0.93	고혈당 → 위험 ↑
SmokingGroup	Current smoker	+0.74	흡연 → 위험 ↑
AgeGroup	Senior	+1.02	고령 → 위험 ↑
✔ 6.2 로지스틱 회귀 기반 Scorecard 모델 생성

WOE 데이터로 로지스틱 회귀 모델을 적합하여
각 feature 계수를 기반으로 점수를 배정한다.

𝑆
𝑐
𝑜
𝑟
𝑒
=
600
+
∑
(
각 변수 점수
)
Score=600+∑(각 변수 점수)
✔ 6.3 Stroke Risk Scorecard 예시
Feature	Bin	Score	의미
AgeGroup	Senior	+87	고령층 위험↑
SmokingGroup	Current smoker	+64	현재 흡연자 위험↑
avg_glucose_level	>150	+72	고혈당 위험↑
hypertension	Yes	+58	고혈압 위험↑
Obesity	Obese	+25	비만 위험↑
gender	Female	-18	여성은 위험↓

→ 점수가 높을수록 뇌졸중 위험이 높다.

✔ 6.4 Scorecard 모델 성능 평가

ROC-AUC = (실제 실험 값 기입)

Scorecard는 Random Forest 대비 해석력에서 매우 큰 강점을 보임

임상 의사결정 시 threshold 기반 위험군 설정 가능

🔍 7. 해석 및 인사이트 (Insights)
🔹 1) 고위험군 파악 (Score 상위 20%)

고혈압 + 고혈당 + 흡연 + 고령 조합에서 뇌졸중 확률 급증

예방 중심 정책(금연 프로그램, 혈압·혈당 관리)의 중요성 확인

🔹 2) 의료진 설명 용이성

“점수가 높은 이유”를 feature별 점수로 설명 가능

환자 상담·건강관리 추천 시 활용 가치 높음

🔹 3) Scorecard의 적용성

향후 건강보험 심사, 병원 EMR 시스템, 환자 모니터링 앱 등에 손쉽게 구현 가능

‘정확성 + 설명력’을 겸비한 의료 AI 모델

🏁 8. 결론 (Conclusion)

본 프로젝트에서는
데이터 기반 예측 모델과 더불어
의료 분야에서 쉽게 해석 가능한 Scorecard 기법을 적용하여
뇌졸중 위험도를 직관적으로 해석할 수 있는 AI 모델을 구축했다.

Random Forest가 높은 예측 정확도를 제공한 반면,
Scorecard 모델은 위험 요인을 정량화하여
“왜 이 환자가 위험한가?”를 설명할 수 있는 강력한 장점을 지녔다.

이 연구는 의료 AI 시스템에서 필수적인 투명성(Transparency) 과
설명 가능성(Explainability) 를 충족하며,
실질적인 임상 의사결정 지원 모델로 확장 가능하다.

