# Hypnos: 뇌파 기반 졸음 감지 서비스

![최종발표-008](https://github.com/user-attachments/assets/e3f90d3d-6349-4a5e-9516-8a188af7dfa8)

![히프노스-전시패널-001](https://github.com/user-attachments/assets/42836344-8a03-4e7b-8520-f374c855294b)

## 프로젝트 개요

Hypnos는 뇌파를 기반으로 운전자의 졸음을 감지하고 예방하는 모바일 애플리케이션입니다. 이 프로젝트는 졸업 작품의 일환으로 개발되었으며, 운전 중 졸음운전으로 인한 사고를 예방하는 것을 목표로 합니다.

![최종 발표 ppt-002](https://github.com/user-attachments/assets/ae9d153f-9de1-4e60-b46b-7de189c0e518)

교통사고 원인의 1위가 졸음운전일 정도로 졸음은 사회에 큰 피해를 일으킵니다. 기존의 연구들은 졸음신호에 대한 명확한 해석이 어렵고, 이미 졸음이 상당히 진행된 상태에서 감지되는 한계가 있습니다. 따라서 근본적인 신호 취득이 가능한 뇌파를 통해 졸음을 조기에 감지하고 대응하는 시스템의 필요성이 대두되었습니다.

## 주요 기능

1. **실시간 운전자 졸음 감지**: Muse2 뇌파 측정 기기를 통해 실시간으로 운전자의 뇌파를 분석하여 졸음 상태를 감지합니다.
2. **졸음 방지 알림**: 졸음 상태 감지 시 사용자가 선택한 음악을 재생하여 졸음을 깨웁니다.
3. **휴식 장소 안내**: 가까운 졸음쉼터나 휴게소로 안내하는 내비게이션 기능을 제공합니다.

## 기술 스택

![005](https://github.com/user-attachments/assets/caba98bd-ce79-4da7-8344-c2b0cc6f6f4d)

- **Frontend**: Swift, Xcode (iOS 앱 개발)
- **Backend**: Node.js, MySQL
- **Data Analysis**: Python
- **Hardware**: Muse2 EEG 헤드셋

## 시스템 아키텍처

1. Muse2 헤드셋을 통해 뇌파 데이터 수집
2. Python을 이용한 뇌파 데이터 분석
3. Node.js 서버를 통해 MySQL 데이터베이스에 데이터 저장
4. iOS 앱에서 Alamofire를 통해 서버와 통신하여 데이터 조회 및 처리

## 주요 화면 구성

![최종-발표-ppt-015](https://github.com/user-attachments/assets/ccc48014-4967-4db6-80d4-305789d5d574)

2. **홈 화면**: 
   - 날짜별 졸음감지 횟수 그래프 표시
   - 선택된 알림 음악 정보
   - Muse 디바이스 연결 상태 표시 및 제어
3. **졸음 감지 알림**: 
   - 실시간 졸음 감지 시 알림 음악 재생
   - 가까운 졸음쉼터 안내 옵션 제공
4. **휴식 장소 안내**: 
   - 졸음쉼터, 휴게소, 주차장, 카페, 공원 등 카테고리별 주변 휴식 장소 목록 제공
   - 카카오 내비게이션 연동

## 데이터 수집 및 분석 과정

![최종 발표 ppt-007](https://github.com/user-attachments/assets/bead19e7-b6ef-46db-a98c-62fc405b0fb4)
<img width="315" alt="뇌파데이터 조회 표" src="https://github.com/user-attachments/assets/fa98f19e-aed7-46dd-9b15-eee6656af26d">

1. **실험 설계**:
   - 피험자: 20명 모집 (전날 수면시간 5시간 이하, 24시간 전 카페인 섭취 금지)
   - 실험 환경: Logitech G29 휠과 페달, City Car Driving 시뮬레이션 프로그램 사용
   - 실험 시간: 60분간 운전 시뮬레이션 진행

2. **데이터 수집**:
   - Muse2 헤드셋 (AF7, AF8, TP9, TP10 채널) 사용
   - 졸음 상태 판단: 하품, 눈 감음 등 관찰하여 마커 표시

3. **데이터 분석**:
   - Bandstop 필터, Hamming window 적용
   - 주파수 대역별 Power 계산
   - 졸음 데이터(1)와 평소 데이터(0) 라벨링

4. **실시간 데이터 처리**:
   - 유저 ID, 시간, 졸음 상태 여부를 서버로 전송
   - 앱에서 Alamofire를 통해 서버와 통신하여 데이터 조회 및 그래프 업데이트

## 프로젝트 성과
![Untitled (6)](https://github.com/user-attachments/assets/6ccfa6cf-8a9c-4565-868c-59a406a61154)

- 한국여성과학기술인육성재단 주관 2023 여대학원생 공학연구팀제 지원사업(심화과정) 참여
- HCI 학회 논문 발표

## 파트 구성

- Frontend 개발
- Backend 개발
- 데이터 분석 및 알고리즘 개발

