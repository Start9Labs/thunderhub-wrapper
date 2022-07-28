THUNDERHUB_SRC := $(shell find ./thunderhub)
VERSION := $(shell yq e ".version" manifest.yaml)

.DELETE_ON_ERROR:

all: verify

clean:
	rm -f thunderhub.s9pk
	rm -f image.tar
	rm -f Dockerfile*
	rm -f scripts/*.js

verify: thunderhub.s9pk
	embassy-sdk verify s9pk thunderhub.s9pk

install: thunderhub.s9pk
	embassy-cli package install thunderhub.s9pk

thunderhub.s9pk: manifest.yaml assets/compat/config_spec.yaml assets/compat/config_rules.yaml image.tar instructions.md scripts/embassy.js 
	embassy-sdk pack

Dockerfile: $(THUNDERHUB_SRC)
	cp thunderhub/Dockerfile Dockerfile
	patch -u Dockerfile -i thunderhub.patch

image.tar: Dockerfile docker_entrypoint.sh check-web.sh
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --tag start9/thunderhub/main:${VERSION} --platform=linux/arm64/v8 -o type=docker,dest=image.tar .

scripts/embassy.js: scripts/**/*.ts
	deno bundle scripts/embassy.ts scripts/embassy.js