# BunKai — Flutter Web app (see README.md).
.PHONY: default site pub-get build-web

default: site

pub-get:
	flutter pub get

site: pub-get
	flutter run -d chrome

build-web: pub-get
	flutter build web
