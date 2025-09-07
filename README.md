## Flutter + WebView(Mapbox GL JS) 통합 개요

이 리포지토리는 Flutter 앱 안에서 WebView로 Mapbox Web SDK(Mapbox GL JS/v3)를 구동해, Flutter가 모든 데이터/권한/I/O를 담당하고 맵뷰는 "렌더링 전용"으로 동작하도록 하는 템플릿 문서를 제공합니다.

- 맵 엔진: Mapbox GL JS (웹)
- 호스팅: Flutter `webview_flutter` (iOS/Android), Flutter Web은 `HtmlElementView`
- 역할 분리: Flutter(데이터/권한/업로드/보안) ↔ 맵뷰(렌더링/지도 이벤트)

### 빠른 시작
1) Flutter 의존성(예시)
```
dependencies:
  webview_flutter: ^4.4.2
  permission_handler: ^11.3.1
  geolocator: ^10.1.0
```

2) 에셋 등록(예시)
```
flutter:
  assets:
    - assets/map/index.html
```

3) Mapbox 토큰 주입
- 런타임 주입을 권장합니다(환경/원격 구성/보안 설정).
- 토큰: `pk.eyJ1IjoicGh5dXppb24iLCJhIjoiY21mOTFnYTg5MGQ4cDJrbzlrNG50c2Z2dyJ9.bQ9adwhAmshtzEuk60R8hA`

4) 구현 가이드와 프로토콜, 권한 전략은 `docs/mapview.md`를 참고하세요.

### 포함 문서
- `docs/mapview.md`: 아키텍처, 명령/이벤트 프로토콜, 권한 처리 전략(앱 주도 권장), 3D 모델/커스텀 마커 구현 방향, 보안/성능 노트

### 플로우 요약
- 메인 → 권한 확인 → 맵 표시(WebView 로드) → 좌상단 버튼(마커/모델)
- 마커 버튼: 위치(lng,lat)·이미지 URL·텍스트 입력 → 저장 → 맵에 렌더
- 모델 버튼: 위치(lng,lat[,alt])·GLTF/GLB URL·스케일(선택)·텍스트(선택) → 저장 → 맵에 렌더
- 다중 추가 가능, 목록은 Flutter가 관리

### 패키지 네임
- `com.tigerfactory.map_test`

### 타깃 플랫폼
- Web, iOS, Android (모두 동일한 메시지/명령 프로토콜 사용)


