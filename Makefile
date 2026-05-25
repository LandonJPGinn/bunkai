# jpquizapp - Flutter Web app (see README.md).
.PHONY: default site pub-get build-web deploy cloudflare-build cloudflare-preview cloudflare-deploy content-export-csv content-furigana-audit content-generate content-validate content-compile content-build d1-seed-sql d1-migrate-local d1-seed-local d1-migrate-remote d1-seed-remote

D1_DATABASE ?= jpquizapp-quiz-content
D1_SEED_SQL ?= cloudflare/d1/seed.generated.sql

default: site

pub-get:
	flutter pub get

site: pub-get
	flutter run -d chrome

build-web: pub-get
	flutter build web

deploy: cloudflare-build d1-migrate-remote d1-seed-remote cloudflare-deploy

cloudflare-build: pub-get
	flutter build web --release --base-href /

cloudflare-preview: cloudflare-build
	npx --yes wrangler@latest dev

cloudflare-deploy:
	npx --yes wrangler@latest deploy

content-export-csv:
	python tool/export_content_csv.py

content-furigana-audit:
	python tool/furigana_audit.py --check

content-generate:
	python tool/build_content_from_csv.py
	dart run scripts/validate_quiz_banks.dart

content-validate:
	dart run scripts/validate_quiz_banks.dart
	flutter test test/services/quiz_bank_loader_test.dart test/services/japanese_dictionary_service_test.dart test/quiz_bank_contract_test.dart test/services/compiled_content_parity_test.dart

content-compile:
	python tool/build_content_from_csv.py --with-arrow --compile-only

content-build: content-generate content-validate content-compile

d1-seed-sql:
	python tool/build_d1_seed.py --output $(D1_SEED_SQL)

d1-migrate-local:
	npx --yes wrangler@latest d1 migrations apply $(D1_DATABASE) --local

d1-seed-local: d1-seed-sql
	npx --yes wrangler@latest d1 execute $(D1_DATABASE) --local --file $(D1_SEED_SQL)

d1-migrate-remote:
	npx --yes wrangler@latest d1 migrations apply $(D1_DATABASE) --remote

d1-seed-remote: d1-seed-sql
	npx --yes wrangler@latest d1 execute $(D1_DATABASE) --remote --file $(D1_SEED_SQL)
