---
name: k-skill
description: 한국 특화 기능(교통·날씨·부동산·쇼핑·법률·금융·공공데이터 등) 요청이 들어오면 실행. git pull로 최신화 후 README 레지스트리에서 스킬을 골라 해당 SKILL.md만 읽어 진행한다.
---

# k-skill

## 실행 순서

1. 저장소를 최신화한다.
   ```bash
   git -C /Users/bachtaeyeong/10_SrcHub/k-skill pull --ff-only
   ```

2. README를 읽어 스킬 인덱스를 확인한다.
   - 파일: `/Users/bachtaeyeong/10_SrcHub/k-skill/README.md`
   - "어떤 걸 할 수 있나" 테이블에서 요청에 맞는 스킬 이름을 고른다.

3. 해당 스킬의 SKILL.md만 읽는다.
   - 파일: `/Users/bachtaeyeong/10_SrcHub/k-skill/<skill-name>/SKILL.md`

4. SKILL.md의 워크플로우를 따라 실행한다.

## 주의

- README 테이블에 ~~취소선~~ 처리된 스킬은 지원 중단 상태이므로 사용하지 않는다.
- "사용자 로그인" 컬럼이 "필요"인 스킬은 실행 전에 사용자에게 로그인 여부를 확인한다.
