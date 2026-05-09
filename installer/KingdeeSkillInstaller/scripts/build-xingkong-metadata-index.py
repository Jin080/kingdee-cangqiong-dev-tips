"""
从 星空元数据xml.txt 提取表单/字段/按钮/单据体标识，输出可 grep 的 JSONL 索引。

输出文件：{BASE_PATH}\\星空元数据-index.jsonl
每行一个表单，包含 form_id、model_type、fields、buttons、entries、plugins。

字段索引同时保留：
- key: 视图/控件层字段标识
- property_name: ORM / model 层实体属性
- field_name: 数据库字段名或底层字段名

用法：
  python build-xingkong-metadata-index.py --input E:\\T1\\星空元数据xml.txt --output E:\\T1\\星空元数据-index.jsonl
"""
from __future__ import annotations

import argparse
import json
import xml.etree.ElementTree as ET
from collections import OrderedDict
from pathlib import Path

BUTTON_TAGS = frozenset({"BarButtonItem", "BarSplitButtonItem", "BarSeperator"})

_NON_FIELD_SUFFIXES = (
    "FieldAppearance",
    "FieldName",
    "FieldType",
    "FieldList",
    "FieldKey",
    "FieldSet",
    "FieldSets",
    "FieldItems",
    "FieldMaps",
    "FieldShowHideAppearance",
)


def _is_field_element(tag: str) -> bool:
    if not tag.endswith("Field"):
        return False
    for suffix in _NON_FIELD_SUFFIXES:
        if tag.endswith(suffix):
            return False
    return True


def _text(el: ET.Element, tag: str) -> str:
    child = el.find(tag)
    return (child.text or "").strip() if child is not None else ""


def parse_form_xml(xml_str: str) -> dict:
    try:
        root = ET.fromstring(xml_str)
    except ET.ParseError as exc:
        return {"parse_error": str(exc)}

    form_el = None
    elements_el = root.find(".//Elements")
    if elements_el is not None:
        for child in elements_el:
            id_el = child.find("Id")
            if id_el is not None and (id_el.text or "").strip():
                form_el = child
                break
    if form_el is None:
        return {"parse_error": "no form element with Id under Elements"}

    form_id = _text(form_el, "Id")
    if not form_id:
        return {"parse_error": "no form Id"}
    model_type = form_el.get("oid", "")

    fields: OrderedDict[str, dict] = OrderedDict()
    for el in root.iter():
        if not _is_field_element(el.tag):
            continue

        key = _text(el, "Key")
        if not key or key in fields:
            continue

        name = _text(el, "Name") or _text(el, "Caption")
        entry = {"key": key, "name": name}

        property_name = _text(el, "PropertyName")
        if property_name:
            entry["property_name"] = property_name

        field_name = _text(el, "FieldName")
        if field_name:
            entry["field_name"] = field_name

        entity_key = _text(el, "EntityKey")
        if entity_key:
            entry["entity_key"] = entity_key

        fields[key] = entry

    buttons: OrderedDict[str, dict] = OrderedDict()
    for section_tag in ("BarItems", "ListMenu"):
        for section in root.iter(section_tag):
            for el in section:
                if el.tag not in BUTTON_TAGS:
                    continue
                key = _text(el, "Key")
                if not key or key in buttons:
                    continue
                buttons[key] = {"key": key, "name": _text(el, "Caption")}

    entries = []
    seen_entries: set[str] = set()
    for el in root.iter("EntryEntity"):
        key = _text(el, "Key")
        if not key or key in seen_entries:
            continue
        seen_entries.add(key)
        entries.append({"key": key, "name": _text(el, "Name")})

    plugins = sorted(
        {
            el.text.strip()
            for el in root.iter("ClassName")
            if (el.text or "").strip()
        }
    )

    result: dict = {"form_id": form_id, "model_type": model_type}
    if fields:
        result["fields"] = list(fields.values())
    if buttons:
        result["buttons"] = list(buttons.values())
    if entries:
        result["entries"] = entries
    if plugins:
        result["plugins"] = plugins
    return result


def build_index(input_file: Path, output_file: Path) -> tuple[int, int, int]:
    ok = err = skipped = 0
    accumulated: list[str] = []
    in_form_record = False

    with (
        open(input_file, encoding="gb18030", errors="replace") as f_in,
        open(output_file, "w", encoding="utf-8") as f_out,
    ):

        def flush_record() -> None:
            nonlocal ok, err
            record = parse_form_xml("\n".join(accumulated))
            if record.get("parse_error"):
                err += 1
                return
            f_out.write(json.dumps(record, ensure_ascii=False) + "\n")
            ok += 1

        for line in f_in:
            line = line.rstrip("\n")

            if line.startswith("<FormMetadata>"):
                if in_form_record:
                    err += 1
                accumulated = [line]
                in_form_record = True
                if "</FormMetadata>" in line:
                    flush_record()
                    accumulated = []
                    in_form_record = False
            elif in_form_record:
                accumulated.append(line)
                if "</FormMetadata>" in line:
                    flush_record()
                    accumulated = []
                    in_form_record = False
            else:
                skipped += 1

        if in_form_record and accumulated:
            err += 1

    return ok, err, skipped


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    print(f"Reading {args.input} ...")
    ok, err, skipped = build_index(args.input, args.output)
    print(f"\nDone -> {args.output}")
    print(f"  Success: {ok}  Parse errors: {err}  Skipped (non-FormMetadata): {skipped}")


if __name__ == "__main__":
    main()
