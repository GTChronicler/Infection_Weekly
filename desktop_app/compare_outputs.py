from __future__ import annotations

import argparse
import sys
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET


NS = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}


def docx_paragraphs(path: Path) -> list[str]:
    with zipfile.ZipFile(path) as archive:
        xml_text = archive.read("word/document.xml")
    root = ET.fromstring(xml_text)
    paragraphs: list[str] = []
    for paragraph in root.findall(".//w:body/w:p", NS):
        texts = [text.text or "" for text in paragraph.findall(".//w:t", NS)]
        paragraphs.append("".join(texts))
    return paragraphs


def read_csv_text(path: Path) -> str:
    return path.read_text(encoding="gbk").replace("\r\n", "\n")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    args = parser.parse_args()

    baseline_docx = args.baseline / "output_beta.docx"
    candidate_docx = args.candidate / "output_beta.docx"
    baseline_csv = args.baseline / "table_beta.csv"
    candidate_csv = args.candidate / "table_beta.csv"

    baseline_paragraphs = docx_paragraphs(baseline_docx)
    candidate_paragraphs = docx_paragraphs(candidate_docx)
    csv_equal = read_csv_text(baseline_csv) == read_csv_text(candidate_csv)
    docx_equal = baseline_paragraphs == candidate_paragraphs

    print(f"CSV_EQUAL={csv_equal}")
    print(f"DOCX_PARAGRAPHS_EQUAL={docx_equal}")
    if not docx_equal:
        for index, (left, right) in enumerate(zip(baseline_paragraphs, candidate_paragraphs), start=1):
            if left != right:
                print(f"FIRST_DOCX_DIFF_PARAGRAPH={index}")
                print(f"BASELINE={left}")
                print(f"CANDIDATE={right}")
                break
        if len(baseline_paragraphs) != len(candidate_paragraphs):
            print(f"BASELINE_PARAGRAPHS={len(baseline_paragraphs)}")
            print(f"CANDIDATE_PARAGRAPHS={len(candidate_paragraphs)}")
    return 0 if csv_equal and docx_equal else 1


if __name__ == "__main__":
    sys.exit(main())
