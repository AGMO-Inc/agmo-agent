# Obsidian 링크 전략

## 내부 링크 (wikilink)

| 연결 | 형태 | 예시 |
|------|------|------|
| 노트 → 프로젝트 인덱스 | `[[{project}]]` | `[[agmo-agent]]` |
| Impl → Plan | `[[{project}/plans/[Plan] 제목]]` | `[[agmo-agent/plans/[Plan] 소유권 변경]]` |
| Plan에 Impl 역링크 | append로 추가 | `- 구현: [[{project}/implementations/[Impl] 제목]]` |

## 외부 링크 (GitHub)

| 대상 | 형태 |
|------|------|
| Issue | `[#42](https://github.com/{OWNER}/{PROJECT}/issues/42)` |
| PR | `[PR #45](https://github.com/{OWNER}/{PROJECT}/pull/45)` |

## 프로젝트 인덱스 허브

모든 Plan/Impl 노트가 `[[{project}]]`를 링크하므로, 인덱스 노트의 backlink 패널에서 전체를 한눈에 볼 수 있다.
