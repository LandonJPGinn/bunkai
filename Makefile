# BunKai — Flutter Web app (see README.md).
.PHONY: default site pub-get build-web content-export-csv content-generate content-validate content-compile content-build

default: site

pub-get:
	flutter pub get

site: pub-get
	flutter run -d chrome

build-web: pub-get
	flutter build web

content-export-csv:
	python tool/export_content_csv.py

content-generate:
	python tool/build_content_from_csv.py
	dart run scripts/validate_quiz_banks.dart

content-validate:
	dart run scripts/validate_quiz_banks.dart
	flutter test test/services/quiz_bank_loader_test.dart test/services/japanese_dictionary_service_test.dart test/quiz_bank_contract_test.dart test/services/compiled_content_parity_test.dart

content-compile:
	python tool/build_content_from_csv.py --with-arrow --compile-only

content-build: content-generate content-validate content-compile
