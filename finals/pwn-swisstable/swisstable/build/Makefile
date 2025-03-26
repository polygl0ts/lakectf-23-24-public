.PHONY : all
all: release

release: build.Dockerfile
	- docker rm tmp-d8-build-container 2>/dev/null
	docker build -t tmp-d8-build-image --build-arg IS_DEBUG=false --build-arg OUT_PATH=release . -f build.Dockerfile
	docker run --name tmp-d8-build-container tmp-d8-build-image /bin/true
	mkdir -p release
	docker cp tmp-d8-build-container:/build/v8/out/release/d8 release/d8
	docker cp tmp-d8-build-container:/build/v8/out/release/snapshot_blob.bin release/snapshot_blob.bin
	- docker rm tmp-d8-build-container 2>/dev/null

debug: build.Dockerfile
	- docker rm tmp-d8-build-container 2>/dev/null
	docker build -t tmp-d8-build-image --build-arg IS_DEBUG=true --build-arg OUT_PATH=debug . -f build.Dockerfile
	docker run --name tmp-d8-build-container tmp-d8-build-image /bin/true
	docker cp tmp-d8-build-container:/build/v8/out/debug/ debug
	- docker rm tmp-d8-build-container 2>/dev/null
