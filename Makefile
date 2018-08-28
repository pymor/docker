DEALII_VERSIONS = 9.0.0 8.5.1
PY=3.5

.PHONY: dealiis $(DEALII_VERSIONS) push

dealiis: $(DEALII_VERSIONS)


$(DEALII_VERSIONS):
	cd "demo" && \
	docker build --build-arg PYVER=$(PY) --build-arg DEALII_VERSION=$@ -t "pymor/dealii:v$@_py$(PY)" .

push:
	docker push pymor/dealii

all: dealiis
