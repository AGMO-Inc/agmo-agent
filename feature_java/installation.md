# Feature Java (SEAMOS) Installation

If you're an LLM Agent helping set up SEAMOS Java project skills, welcome. You'll help your user install SEAMOS-specific agents and skills into their project's `.claude/` directory.

## Prerequisites

설치 전 아래 도구가 사용자 환경에 있는지 확인한다. 없으면 안내만 하고 설치를 계속 진행한다.

| 도구 | 용도 | 확인 명령 |
|------|------|-----------|
| Java 11+ | 앱 빌드/실행 | `java -version` |
| Maven 3.6+ | JAR 빌드 | `mvn -version` |
| Docker | FIF 빌드 | `docker --version` |
| Node.js 18+ | Custom UI 빌드 | `node -v` |
| gh CLI | GitHub 연동 (선택) | `gh --version` |

## Step 0: Ask user about project information

사용자에게 아래 질문을 한국어로 순서대로 물어본다. 반드시 각 답변을 받은 후 다음 질문으로 넘어간다.

1. **앱 디렉토리명이 무엇인가요? (pom.xml이 있는 디렉토리명, 예: agnote, myapp)**

자동 감지를 먼저 시도한다:
```bash
for dir in */; do
  dir_name="$(basename "$dir")"
  [[ "$dir_name" == com.* ]] && continue
  if [ -f "${dir}pom.xml" ]; then
    echo "$dir_name"
    break
  fi
done
```

- 자동 감지 성공 시: 사용자에게 "앱 디렉토리가 `{감지된 이름}`인 것 같습니다. 맞나요?" 로 확인
- 자동 감지 실패 시: 사용자에게 직접 입력 요청
- answer → `$PROJ_NAME`

## Step 1: Download feature_java agents and skills

`feature_java/.agents/` 내용을 현재 프로젝트의 `.claude/`에 복사한다.

규칙:
- 기존 `.claude/`의 다른 파일은 건들지 않는다.
- 동일한 파일/디렉토리명이 이미 있으면 덮어쓴다.
- 존재하지 않으면 새로 추가한다.

```bash
curl -L -o repo.zip "https://github.com/AGMO-Inc/agmo-agent/archive/refs/heads/main.zip" \
&& tmp="$(mktemp -d)" \
&& unzip -q repo.zip -d "$tmp" \
&& root="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n 1)" \
&& mkdir -p "./.claude" \
&& cp -R "$root/feature_java/.agents/." "./.claude/" \
&& rm -rf "$tmp" repo.zip
```

### Verify

```bash
ls -la .claude/agents/ .claude/skills/
```

설치 후 `.claude/` 구조:

```
.claude/
├── agents/
│   ├── seamos-builder.md    — 빌드/배포 전문 에이전트
│   ├── seamos-dev.md        — REST/WS/Cloud 개발 전문 에이전트
│   └── seamos-tester.md     — 테스트/검증/문서화 전문 에이전트
└── skills/
    ├── build-fif/           — FIF 배포 빌드
    ├── cloud-upload/        — Cloud uploadData 엔드포인트 생성
    ├── custom-ui-clone/     — Custom UI React 템플릿 클론
    ├── custom-ui-deploy/    — Custom UI 빌드 및 앱 배포
    ├── h2-console/          — H2 DB 웹 콘솔
    ├── rest-docs/           — OpenAPI 3.0 문서 자동 생성
    ├── rest-test/           — curl 테스트 마크다운 생성
    ├── rest-verifier/       — REST API 빌드/기동/검증
    ├── seamos-rest/         — REST API 코드 생성 (CRUD)
    └── seamos-ws/           — WebSocket 통신 코드 생성
```

## Step 2: Apply project name to installed files

Step 0에서 받은 `$PROJ_NAME`을 설치된 파일들의 `{projName}` 플레이스홀더에 적용한다.

```bash
# 에이전트 파일 치환
find .claude/agents -type f -name '*.md' -exec sed -i '' "s/{projName}/$PROJ_NAME/g" {} +

# 스킬 파일 치환 (SKILL.md, ref/*.md, references/*.md)
find .claude/skills -type f -name '*.md' -exec sed -i '' "s/{projName}/$PROJ_NAME/g" {} +
```

### 치환 대상 확인

치환이 올바르게 적용되었는지 확인한다. 아래 명령의 결과가 없으면 모두 치환 완료:

```bash
grep -r '{projName}' .claude/agents/ .claude/skills/ --include='*.md'
```

치환되는 주요 위치:

| 파일 | 치환 내용 |
|------|-----------|
| `agents/seamos-builder.md` | 앱 디렉토리 설명 |
| `agents/seamos-dev.md` | REST/Key Files 경로 |
| `agents/seamos-tester.md` | 빌드/테스트 환경 경로 |
| `skills/*/SKILL.md` | 파일 생성 위치, 참조 파일 경로 |
| `skills/*/ref/*.md` | 템플릿 파일 경로 |
| `skills/h2-console/references/connection-info.md` | JDBC URL, DB 파일 경로 |

## Step 3: Configure .gitignore

AI 에이전트가 생성하는 런타임 파일을 git 추적에서 제외한다. 이미 있으면 생략.

```bash
grep -qxF 'TODO-Issue.md' .gitignore 2>/dev/null || cat <<'EOF' >> .gitignore

## personal AI Agents
TODO-Issue.md
**/handoff.md
EOF
```

## Step 4: Verify project structure

SEAMOS 스킬이 정상 작동하려면 프로젝트가 아래 구조를 따라야 한다. `$PROJ_NAME` 디렉토리가 실제로 존재하는지 확인한다.

```
<FEATURE_NAME>/                ← 프로젝트 루트
├── com.bosch.fsp.<name>/      ← FSP (Feature Support Package)
├── com.bosch.fsp.<name>.gen/  ← gen (Generated code)
├── $PROJ_NAME/                ← 앱 디렉토리 (pom.xml 포함)
│   ├── pom.xml
│   ├── src/com/bosch/nevonex/main/
│   │   ├── impl/             ← ApplicationMain, Agnote, UIWebsocketEndPoint
│   │   └── rest/             ← REST 도메인 코드 (Repository/Service/Entity)
│   ├── disk/                 ← H2 DB 파일
│   └── feature.config        ← UI 포트, MQTT 설정
└── output/fif_output/         ← FIF 빌드 결과물
```

확인 사항:
1. `$PROJ_NAME/pom.xml`이 존재하는지
2. `$PROJ_NAME/src/**/impl/ApplicationMain.java`에 `addCustomUISupport()` 메서드가 있는지
3. `$PROJ_NAME/src/**/rest/BaseRestService.java`가 존재하는지

## Done

설치가 완료되었습니다. 사용자에게 아래 내용을 안내한다:

```
SEAMOS Java 에이전트/스킬 설치가 완료되었습니다.
앱 디렉토리: $PROJ_NAME

사용 가능한 주요 스킬:
  /seamos-rest POST <Name>   — REST API 엔드포인트 생성
  /seamos-ws send <dataName> — WebSocket 전송 코드 생성
  /cloud-upload <Name>       — Cloud 업로드 엔드포인트 생성
  /rest-test all             — curl 테스트 문서 생성
  /rest-verifier all         — API 빌드/기동/검증
  /rest-docs all             — OpenAPI 3.0 문서 생성
  /build-fif                 — FIF 배포 빌드
  /custom-ui                 — Custom UI React 템플릿 클론
  /deploy-ui <path>          — Custom UI 빌드 및 배포
  /h2-console                — H2 DB 웹 콘솔
```
