# dayplan_it

Dayplan.it 프론트엔드 개발

# 개발 가이드라인

## 색상, Padding 등

`constraints.dart`에 있음. 왠만하면 통일을 위해 여기에서 색상이나 패딩값 가져다 쓰는게 좋을듯

## Screens

- `main.dart`에서 네비바 클릭할때마다 각 화면 왔다갔다함

- 각 스크린별로 폴더를 만들어 관리
  - 각 폴더 내에는 메인 화면 파일을 두고, 각 `components`폴더 내에 컴포넌트들을 모아두기
- `lib/components`에는 앱바 및 네비게이션 바가 있음
- `assets/icons` 내에 로고가 있음
- 폰트는 google에서 제공하는 폰트를 사용하는게 좋을듯
  - 메인 폰트 미결정
  - 로고 폰트는 `constraints.dart`에 있음

# 4/13 태훈

### api키 넣을 곳

- ios/Runner/AppDelegate.swift
- android/app/src/main/AndroidManifest.xml

### 콘솔창에서 라이브러리 다운로드

```
flutter pub add flutter_polyline_points
```

```
flutter pub add google_maps_flutter
```

```
flutter pub add calendar_strip
```

# 태훈 - 메인화면

### DB의 API적용

- (테스트: 일정을 갖고 있는 회원id가 30)
- 구글API키 입력해야함
- 테스트 환경 : IOS만 수행

1. 회원id가 가지고 있는 일정(schedule) 받아와서 일정있는 날에 마크
2. 캘린더에서 해당날짜를 누르면 일정정보, 지도에 장소, 루트 표시하고 확대
3. 다른날짜누르면 초기화
