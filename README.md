# yk

개인용 웹앱 모음.

| 앱 | 주소 | 설명 |
|---|---|---|
| [오늘의 한 쪽](diary/) | `encosn.github.io/yk/diary/` | 달력으로 쓰는 개인 일기장 |

저장소는 공개지만, 일기 내용은 여기 올라오지 않습니다.
글과 사진은 Supabase 에 들어가고 행 수준 보안(RLS)으로 본인만 열 수 있습니다.

---

## 오늘의 한 쪽 — 설치

### 1. Supabase 프로젝트 만들기

[supabase.com](https://supabase.com) → **New project**.
이름은 아무거나(`diary` 정도), 지역은 **Northeast Asia (Seoul)** 을 고르면 가장 빠릅니다.
데이터베이스 비밀번호는 따로 적어 두세요(일기 로그인 비밀번호와는 다른 것입니다).

### 2. 표와 보안 규칙 만들기

프로젝트 왼쪽 메뉴 **SQL Editor** → **New query** 에
[`supabase/schema.sql`](supabase/schema.sql) 을 통째로 붙여 넣고 **Run**.

일기 표, 사진 보관함, 그리고 "본인 것만 읽고 쓴다"는 보안 규칙이 한 번에 만들어집니다.

### 3. 내 계정 만들기 — 그리고 남의 가입 막기

**Authentication → Users → Add user → Create new user**
이메일과 비밀번호를 넣고, **Auto Confirm User** 를 켠 채로 만듭니다.
이 이메일과 비밀번호로 일기장에 들어갑니다.

이어서 **Authentication → Sign In / Providers → Email** 에서
**Allow new users to sign up** 을 **끕니다.**
이걸 꺼야 주소를 아는 남이 제 계정을 만들어 들어오는 일이 없습니다.

### 4. 연결 정보 채우기

**Connect**(화면 위쪽) → **App Frameworks** 에서 두 값을 복사해
[`diary/index.html`](diary/index.html) 맨 위 `DIARY_CONFIG` 에 넣습니다.

```js
window.DIARY_CONFIG = {
  url: "https://xxxxxxxxxxxx.supabase.co",
  key: "sb_publishable_..."      // 또는 eyJhbGciOi... (anon public)
};
```

`sb_secret_...` 이나 `service_role` 키는 **절대 넣지 마세요.**
위 두 값은 원래 브라우저에 공개되는 값이고, 실제 잠금은 3단계에서 만든 보안 규칙이 맡습니다.

### 5. GitHub Pages 켜기

저장소 **Settings → Pages → Source: Deploy from a branch → `main` / `(root)`** → Save.
1~2분 뒤 `https://encosn.github.io/yk/diary/` 로 열립니다.

휴대폰에서는 브라우저 메뉴의 **홈 화면에 추가**를 하면 앱처럼 열립니다.

---

## 쓰는 법

- 달력에서 **빈 날을 누르면** 작성 창 — 제목, 기분, 사진, 본문
- **쓴 날에는 연필**이 나타나고, 기분을 골랐으면 이모지도 같이 붙습니다
- **그 칸을 누르면** 내용 보기 → **수정 / 삭제** (삭제는 한 번 더 확인)
- 위쪽 **검색창**으로 일기 속 낱말 찾기
- 오른쪽 위 **잠그기**로 로그아웃

사진은 긴 변 1600px로 줄여서 올라갑니다.
무료 Supabase 의 저장 공간은 1GB이니, 한 장 200KB 기준으로 몇 천 장은 넉넉합니다.
