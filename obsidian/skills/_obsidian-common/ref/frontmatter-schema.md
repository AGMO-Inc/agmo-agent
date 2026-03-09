# Frontmatter 스키마

## Plan 노트

```yaml
---
type: plan
project: {PROJECT}
issue: null
issue-type: feature | task | bug
status: draft | issued | in-progress | done
created: YYYY-MM-DD
tags:
  - plan
  - {PROJECT}
---
```

## Implementation 노트

```yaml
---
type: impl
project: {PROJECT}
issue: "#번호"
pr: "#번호"
plan: "[[{PROJECT}/plans/[Plan] 제목]]"
status: in-progress | done
created: YYYY-MM-DD
tags:
  - impl
  - {PROJECT}
---
```

## Design 노트

```yaml
---
type: design
project: {PROJECT}
status: draft | review | done
created: YYYY-MM-DD
tags:
  - design
  - {PROJECT}
---
```

## Research 노트

```yaml
---
type: research
project: {PROJECT}
status: draft | done
created: YYYY-MM-DD
tags:
  - research
  - {PROJECT}
---
```

## Meeting 노트

```yaml
---
type: meeting
project: {PROJECT}
date: YYYY-MM-DD
attendees: []
created: YYYY-MM-DD
tags:
  - meeting
  - {PROJECT}
---
```

## Memo 노트

```yaml
---
type: memo
project: {PROJECT}
created: YYYY-MM-DD
tags:
  - memo
  - {PROJECT}
---
```

## 프로젝트 인덱스 노트

```yaml
---
type: project-index
project: {PROJECT}
repo: {OWNER}/{PROJECT}
project-url: https://github.com/orgs/{OWNER}/projects/{N}
tags:
  - project
---
```
