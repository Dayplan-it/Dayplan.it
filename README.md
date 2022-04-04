# Dayplan.it

**Frontend, Backend에 각각 README 있으니 참고하기**
[Backend README](/backend/README.md)

# 협업전략

전체적으로 [이 글을 읽고](https://velog.io/@cos/Github%EC%97%90%EC%84%9C-%ED%98%91%EC%97%85%ED%95%98%EB%8A%94-%EB%B0%A9%EB%B2%95) 짠 전략으로, 꼭 읽어보길 바람!!

## Branch 전략 - Feature Branch Workflow

1. `Github`에서 이슈 생성, 번호 확인
2. 로컬에서 `issue/#이슈번호` 형식으로 새로운 브랜치를 생성하고, 새 작업 브랜치를 원격 저장소로 push

- 이 때 가능하다면 이슈에 적절한 라벨 붙이기

3. 이슈에 적은 목표를 달성
4. 로컬에서 테스트
5. 수정 사항을 commit하고 원격 저장소로 push
6. PR 날리고 Reviewer로 상대방 지정하기
7. 지정된 Reviewer는 코드 보고 코멘트 남기기
8. 리뷰 과정을 거친 후 작업 브랜치를 메인 브랜치에 merge
9. issue를 닫고 작업 브랜치 삭제

## Projects Board

- 깃허브에서 제공하는 Projects 보드 활용하기 (ex: [DB Board](https://github.com/Dayplan-it/Dayplan.it/projects/1))

## Commit Message 전략

- `50/72 규칙`
  - 첫 줄에 50자 이내로 커밋 내용을 요약하기
  - 첫 줄로 부족하다면 두번째 줄을 비우고 세번째 줄부터 상세 내용을 적기.
    - 이 때, 한 줄을 72자 이내로 하기 (Git이 커밋 메세지를 보여줄 때 4자 들여쓰기를 하기 때문에 80자 출력을 기준으로 커밋 메세지를 중앙에 위치시키는 것이 목적이라고 함)
