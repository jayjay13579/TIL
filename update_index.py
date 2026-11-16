from pathlib import Path

root = Path(__file__).parent
readme = root / "README.md"

start = "<!-- TIL-INDEX:START -->"
end = "<!-- TIL-INDEX:END -->"

files = sorted(
    root.glob("[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9].md"),
    reverse=True,
)

lines = []
for file in files:
    year, month, day = file.parts[-3:]
    date = f"{year}-{month}-{Path(day).stem}"
    lines.append(f"- [{date}](./{file.relative_to(root).as_posix()})")

content = readme.read_text(encoding="utf-8")
before, rest = content.split(start, 1)
_, after = rest.split(end, 1)

index = "\n".join(lines) or "아직 기록이 없습니다."
updated = f"{before}{start}\n{index}\n{end}{after}"

readme.write_text(updated, encoding="utf-8")
print(f"목차를 갱신했습니다. ({len(files)}개)")