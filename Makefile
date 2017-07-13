# Name of the image
name := stelcheck/couchbase
imageVersion := 1

# Latest Node version supported
latest := community-4.5.1

# Default set of version for `make all`
versions := \
	$(latest)

# Default version for `make build`
version := $(latest)

build-version:
	sed "s/^FROM IMAGE/FROM couchbase\/server:$(version)/" Dockerfile.tpl > Dockerfile
	docker build -t $(name):$(version)-$(imageVersion) .
	[[ "$(version)" == "$(latest)" ]] && docker tag $(name):$(version)-$(imageVersion) $(name):latest || true
	rm Dockerfile

build:
	for version in $(versions); do \
		echo ">> Building version $${version}"; \
		$(MAKE) build-version version=$${version} || exit $${?}; \
	done

release-version:
	docker push $(name):$(version)-$(imageVersion)

git-push:
	git push git@github.com:stelcheck/docker-couchbase.git master

release: git-push
	for version in $(versions); do \
		echo ">> Release version $${version}"; \
		$(MAKE) release-version version=$${version}; \
	done
	$(MAKE) release-version version=latest