## 맵뷰 설계 가이드 (Flutter + WebView + Mapbox GL JS)

이 문서는 Flutter 앱에서 WebView를 사용해 Mapbox Web SDK(GL JS/v3)를 구동하고,
Flutter가 데이터/권한/I/O를 담당하는 "앱 주도" 아키텍처를 설명합니다.

### 목표
- Flutter는 업로드/권한/네트워크/보안을 담당
- 맵뷰는 렌더링 전용(지도, 마커, 레이어, 3D 모델 등)
- 양방향 통신은 안전한 JSON 메시지 프로토콜로 표준화

---

## 1. 구성 요소
- Flutter 앱: `webview_flutter`로 `assets/map/index.html` 로드
- MapView(웹): Mapbox GL JS와 보조 라이브러리(Three.js)를 포함
- 메시지 브릿지: `WebViewController.runJavaScript`(Flutter→JS), `JavaScriptChannel`(JS→Flutter)

---

## 2. 보안/토큰
- Mapbox Access Token은 Flutter가 런타임에 주입(환경·원격 설정) → JS에서 변수로 수신
- 토큰 하드코딩은 지양. 필요 시 앱 레벨에서 회전/갱신 가능

주입 예(Flutter→JS):
```dart
await controller.runJavaScript("window.mapview?.setToken('${String.fromEnvironment('MAPBOX_TOKEN')}')");
```

JS 수신 예:
```js
window.mapview = window.mapview || {};
window.mapview.setToken = (token) => {
  mapboxgl.accessToken = token;
};
```

---

## 3. 메시지 프로토콜
버전 필드를 포함하고, 명령/이벤트를 분리합니다.

### 3.1 Flutter → MapView (명령)
공통 필드: `v`, `type`, `id?`

명령 예시:
```json
{ "v":1, "type":"setStyle", "style":"mapbox://styles/mapbox/streets-v12" }
{ "v":1, "type":"setCamera", "center":[126.9784,37.5665], "zoom":13, "pitch":60, "bearing":-17, "durationMs":800 }
{ "v":1, "type":"addMarker", "id":"marker_gwang", "lngLat":[126.9769,37.5759],
  "popupHtml":"<b>광화문</b>",
  "icon":{"kind":"url","value":"https://cdn.example.com/gwang.png","size":[56,56],"anchor":"bottom"} }
{ "v":1, "type":"addModel", "id":"model_cityhall", "lngLatAlt":[126.9771,37.5647,0],
  "model":{"kind":"url","value":"https://cdn.example.com/cityhall.glb","scale":1.0} }
```

지원 명령(초안):
- 카메라: `setCamera`, `fitBounds`
- 스타일/환경: `setStyle`, `setFog`, `setLight`
- 소스/레이어: `addGeoJson`, `updateGeoJson`, `addLayer`, `setLayout`, `setPaint`, `removeLayer`
- 엔티티: `addMarker`, `updateMarker`, `removeMarker`, `addModel`, `updateModel`, `removeModel`
- 유틸: `clearScene`

큐잉 전략: 맵 준비 전 도착한 명령은 큐에 저장 후 `mapReady` 시 일괄 처리.

### 3.2 MapView → Flutter (이벤트)
공통 필드: `v`, `event`, `payload`

이벤트 예시:
```json
{ "v":1, "event":"mapReady" }
{ "v":1, "event":"markerClick", "payload": { "id":"marker_gwang" } }
{ "v":1, "event":"cameraMove", "payload": { "center":[126.978,37.566], "zoom":13.2 } }
{ "v":1, "event":"error", "payload": { "code":"MODEL_LOAD_FAIL", "message":"..." } }
```

---

## 4. 권한 처리 전략

### 권장: 앱 주도(App-driven)
- 위치 권한/정확도, 백그라운드 허용 등은 Flutter에서 담당(`permission_handler`, `geolocator` 등)
- 위치 스트림을 앱에서 구독 후, 주기/임계값을 제어하여 MapView로 `updateLocation` 명령 전달
- 장점: 일관된 UX, 플랫폼 고유 정책 준수, WebView 제한 회피, 오프라인/프라이버시 제어 용이

Flutter 측 예시(요약):
```dart
final granted = await Geolocator.requestPermission();
final pos = await Geolocator.getCurrentPosition();
sendToMap({
  'v': 1,
  'type': 'updateLocation',
  'lngLat': [pos.longitude, pos.latitude],
  'accuracy': pos.accuracy,
});
```

MapView 처리 예시:
```js
case 'updateLocation':
  // 내부 user-location 소스/레이어 갱신 or 마커 이동
  break;
```

### 대안: 웹뷰 주도(Web-driven)
- JS에서 Geolocation API를 사용해 위치를 직접 요청
- 단, iOS/Android WebView의 권한 프롬프트/정책 차이와 HTTPS 요구사항을 고려해야 함
- 업로드/파일 접근은 WebView 보안 제약이 크므로 비권장

결론: 위치 권한은 앱이 관리하고, 맵뷰는 전달받은 좌표를 렌더(마커/레이어 업데이트)하는 구조가 가장 안전/안정적입니다.

---

## 5. 3D 모델 & 커스텀 마커

### 커스텀 마커(광화문)
- HTML 기반 `mapboxgl.Marker` 사용, Popup/상호작용 지원
- 이미지는 URL 권장, Base64는 대용량 회피

### 3D 모델(시청역)
- 선택 1) Mapbox GL JS v3 모델 레이어(정적/간단 구성)
- 선택 2) Three.js 커스텀 레이어 + GLTFLoader(애니메이션/이동/회전 등 고유 로직 유연)
- 이동/회전은 rAF 루프에서 변환 갱신

---

## 6. 성능 & 안정성
- 명령 배치/스로틀링: 16ms 단위 coalesce
- 대용량 Base64 지양, URL/로컬 서버 활용, Blob URL 사용 시 `URL.revokeObjectURL`
- 에러 핸들링: JSON 스키마 검증, 타임아웃/재시도, 이벤트로 실패 통지
- 모바일 WebGL 이슈: 기기별 드라이버 호환성 체크, 폴백 경로 준비

---

## 7. 좌표 예시
- 광화문: [126.9769, 37.5759]
- 시청역: [126.9771, 37.5647]
- 초기 카메라(서울 시청 인근): center [126.9784, 37.5665], zoom 13, pitch 60, bearing -17

---

## 8. 체크리스트
- [ ] 토큰 런타임 주입
- [ ] 권한: 앱 주도 + 위치 스트림 전달
- [ ] 명령/이벤트 브릿지 구현
- [ ] 광화문 마커 추가
- [ ] 시청역 3D 모델 추가(움직임)

---

## 9. UX 플로우 및 화면 요소

### 9.1 전체 플로우(웹/ios/android 공통)
1) 메인 화면 → "권한 확인" 단계 표시
2) 위치 권한 요청/검증(앱 주도). 성공 시 현재 위치/정확도 확보
3) 맵 표시(WebView 로드) 및 `mapReady` 대기
4) 좌상단에 버튼 2개 노출
   - 마커 생성
   - 모델 생성
5) 각 버튼 클릭 시 입력 팝업 표시(모바일은 BottomSheet 대체 가능)
   - 위치(lng, lat) 입력 또는 "지도에서 선택"(선택 시 지도 탭 모드)
   - 이미지 URL(마커), 텍스트(설명)
   - 모델 URL(GLB/GLTF), 스케일(기본 1.0), 텍스트(설명 선택)
6) 저장 시 Flutter가 명령(JSON) 생성 → 맵뷰로 전송 → 즉시 렌더
7) 여러 개 반복 추가 가능. 리스트는 Flutter에서 관리(식별자/메타 포함)

참고: 텍스트는 Popup/설명용으로 선택 입력. 필수는 아님

### 9.2 입력 팝업 필드
- 마커 생성
  - 위치: 경도(lng), 위도(lat)
  - 이미지 URL: https://... (권장)
  - 텍스트(선택): 설명/타이틀 HTML 가능
- 모델 생성
  - 위치: 경도(lng), 위도(lat), 고도(선택)
  - 모델 URL: https://.../.glb(.gltf)
  - 스케일(선택): 기본 1.0
  - 텍스트(선택)

### 9.3 식별자/리스트 관리
- Flutter가 고유 `id` 생성(`marker_...`, `model_...`)
- 로컬 상태에 목록 보관(추가/편집/삭제)
- 맵 클릭/엔티티 클릭 이벤트는 `id` 기반으로 상호작용

---

## 10. 명령 스키마(초안)

### 10.1 마커 관련
```json
{ "v":1, "type":"addMarker", "id":"marker_001",
  "lngLat":[126.9769,37.5759],
  "icon": { "kind":"url", "value":"https://.../marker.png", "size":[56,56], "anchor":"bottom" },
  "popupHtml":"<b>광화문</b><br/>설명 텍스트" }
```

```json
{ "v":1, "type":"updateMarker", "id":"marker_001",
  "lngLat":[126.9770,37.5758],
  "icon": { "kind":"url", "value":"https://.../marker2.png" } }
```

```json
{ "v":1, "type":"removeMarker", "id":"marker_001" }
```

### 10.2 모델 관련
```json
{ "v":1, "type":"addModel", "id":"model_001",
  "lngLatAlt":[126.9771,37.5647,0],
  "model": { "kind":"url", "value":"https://.../cityhall.glb", "scale":1.0 },
  "popupHtml":"<b>시청역 모델</b>" }
```

```json
{ "v":1, "type":"updateModel", "id":"model_001",
  "lngLatAlt":[126.9773,37.5646,0],
  "model": { "scale":1.2 } }
```

```json
{ "v":1, "type":"removeModel", "id":"model_001" }
```

### 10.3 카메라/환경
```json
{ "v":1, "type":"setCamera", "center":[126.9784,37.5665], "zoom":13, "pitch":60, "bearing":-17, "durationMs":800 }
{ "v":1, "type":"fitBounds", "bounds":[[126.97,37.56],[126.99,37.58]], "padding":40 }
{ "v":1, "type":"setStyle", "style":"mapbox://styles/mapbox/streets-v12" }
```

### 10.4 위치 업데이트(앱 주도)
```json
{ "v":1, "type":"updateLocation", "lngLat":[126.978,37.566], "accuracy":15 }
```

---

## 11. 플랫폼 체크리스트

### 공통
- 런타임 토큰 주입(환경/원격)
- HTTPS 사용(모델/이미지 URL)
- 메시지 스키마 검증/로그/에러 통지

### iOS
- `WKWebView` 기본, 하드웨어 가속 활성
- `Info.plist`: 위치 권한 문구(NSLocationWhenInUseUsageDescription 등) 및 ATS 예외(URL 필요 시)
- 위치는 Flutter에서 획득 후 전달

### Android
- WebView 최신 유지, `android:hardwareAccelerated="true"`
- 위치 권한(정밀/백그라운드 필요 여부 검토)
- 위치는 Flutter에서 획득 후 전달

### Web
- Flutter Web 대상일 경우 `HtmlElementView`로 동일 HTML 로드
- 위치 권한은 브라우저 정책 준수(대체로 앱 주도 설계와 동일 명령 흐름 유지)

---

## 12. 패키지 네임/환경 변수
- 앱 패키지 네임: `com.tigerfactory.map_test`
- 환경 변수 예시
  - `MAPBOX_TOKEN` = `pk.eyJ1IjoicGh5dXppb24iLCJhIjoiY21mOTFnYTg5MGQ4cDJrbzlrNG50c2Z2dyJ9.bQ9adwhAmshtzEuk60R8hA`
- 빌드 시 런타임 주입 전략 사용(예: 앱 내 보안 저장소/원격 구성)

---

## 13. Web 타깃 실행(우선 테스트 경로)

### 13.1 사전 준비
- Flutter Web 활성화: `flutter config --enable-web`
- 디바이스 확인: `flutter devices`
  - `Chrome` 또는 `Web Server`가 보이면 준비 완료

### 13.2 실행 명령
- 기본(Chrome): `flutter run -d chrome`
- Edge로 직접 실행(인식될 때): `flutter run -d edge`
- 웹 서버로 띄우고 Edge로 수동 접속: `flutter run -d web-server` (출력된 URL을 Edge에 붙여넣기)

렌더러 권장값
- 초기엔 `--web-renderer html`로 시작(경량), 필요시 `canvaskit`로 전환
  - 예: `flutter run -d chrome --web-renderer html`

### 13.3 Web에서의 맵 호스팅 방식
- 모바일(WebView) 대신 Web에선 `HtmlElementView`로 직접 `div#map`에 Mapbox GL JS를 초기화하거나,
  동일한 `assets/map/index.html`을 `IFrameElement`로 임베드하여 메시지(`postMessage`)로 명령/이벤트를 주고받습니다.
- 장점: 모바일과 거의 동일한 HTML/JS 재사용, 명령 프로토콜 동일 유지

메시지 브릿지(개념)
- Flutter(Web) → iframe: `iframe.contentWindow.postMessage({ ...cmd }, '*')`
- iframe(JS) → Flutter(Web): `window.parent.postMessage({ ...event }, '*')`
- 보안: origin 화이트리스트/토큰 검증 고려

### 13.4 CORS/보안/권한 주의
- GLB/PNG 등 외부 자산은 HTTPS와 CORS 허용 헤더 필요(`Access-Control-Allow-Origin`)
- Geolocation은 HTTPS 또는 `http://localhost`에서만 작동(웹 정책)
- 토큰/비밀 값은 런타임 주입 및 로깅 마스킹

### 13.5 빌드
- 프로덕션 빌드: `flutter build web --release`
- 빌드 산출물: `build/web/`

### 13.6 Edge 고정 실행(옵션)
Flutter CLI는 "기본 디바이스"를 영구 저장하는 옵션이 없습니다. 아래 중 하나로 고정 실행을 구성하세요.

1) VS Code
-.vscode/launch.json에 디바이스와 인자를 지정
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Web (Edge)",
      "request": "launch",
      "type": "dart",
      "deviceId": "edge",
      "args": ["--web-renderer", "html"]
    }
  ]
}
```

2) Android Studio / IntelliJ
- Run/Debug Configurations → Flutter → 새 구성 생성
- Additional run args: `-d edge --web-renderer html`

3) 쉘 별칭(추천)
- macOS zsh: `~/.zshrc`에 추가 후 `source ~/.zshrc`
```bash
alias frwe='flutter run -d edge --web-renderer html'
```
사용: `frwe`

4) Makefile
```makefile
run-web-edge:
	flutter run -d edge --web-renderer html
```
사용: `make run-web-edge`

5) 전역 렌더러 기본값 설정(선택)
- 장치 고정은 불가하지만 렌더러는 전역 설정 가능
```bash
flutter config --web-renderer html
```


