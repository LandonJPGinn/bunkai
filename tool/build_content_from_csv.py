#!/usr/bin/env python3
import argparse

from content_pipeline import compile_arrow_artifacts, generate_assets_from_csv


def main() -> None:
    parser = argparse.ArgumentParser(description="Build content assets from CSV.")
    parser.add_argument(
        "--with-arrow",
        action="store_true",
        help="Also compile Arrow feather artifacts.",
    )
    parser.add_argument(
        "--compile-only",
        action="store_true",
        help="Skip CSV->JSON generation and only compile Arrow artifacts.",
    )
    args = parser.parse_args()

    if not args.compile_only:
        generate_assets_from_csv()
    if args.with_arrow:
        compile_arrow_artifacts()


if __name__ == "__main__":
    main()
