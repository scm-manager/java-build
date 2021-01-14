VERSION:=11.0.9.1_1-1

.PHONY:build
build:
	docker build -t scmmanager/java-build:${VERSION} .

.PHONY:publish
publish: build
	docker push scmmanager/java-build:${VERSION}
