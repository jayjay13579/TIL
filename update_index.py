from pathlib import Path
from urllib.parse import quote

root = Path(__file__).parent
readme = root / "README.md"

start = "<!-- TIL-INDEX:START -->"
end = "<!-- TIL-INDEX:END -->"

files = sorted(
    (
        file
        for file in root.glob("stage*/*")
        if file.is_file()
    ),
    key=lambda file: (
        not file.name[:6].isdigit(),  # ← 수정: 날짜가 없는 파일은 아래로
        file.name[:6],                # ← 수정: 앞 6자리 날짜를 오래된 순으로
        file.name,                    # 같은 날짜면 파일명순으로 정렬
    ),
)

lines = []
for file in files:
    title = file.name
    path = quote(file.relative_to(root).as_posix(), safe="/")
    lines.append(f"- [{title}](./{path})")

content = readme.read_text(encoding="utf-8")
before, rest = content.split(start, 1)
_, after = rest.split(end, 1)

index = "\n".join(lines) or "아직 기록이 없습니다."
updated = f"{before}{start}\n{index}\n{end}{after}"

readme.write_text(updated, encoding="utf-8")
print(f"목차를 갱신했습니다. ({len(files)}개)")