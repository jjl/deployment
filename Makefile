CURRENT_PACKAGE = $(PWD)
PARENT_PACKAGE = $(PWD)/..

NPM_MASTER = http://registry.npmjs.org/
NPM_MANIFESTS = $(PARENT_PACKAGE)/package.json
NPM_MIRROR_HOST = http://localhost:8080/npm/
NPM_MIRROR_PATH = $(PWD)/mirrors/npm

PIP_MASTER = http://pypi.python.org/simple/
PIP_REQUIREMENTS = $(PARENT_PACKAGE)/requirements.txt
PIP_MIRROR_PATH = $(PWD)/mirrors/pypi

# Dependencies of the project we're embedded in
npm-mirror: npm-mirror-dir
	DEBUG=npm-mirror:SyncManager \
	npm-mirror --master $(NPM_MASTER) --manifests $(NPM_MANIFESTS) \
	--hostname $(NPM_MIRROR_HOST) --root $(NPM_MIRROR_PATH)

# Dependencies of this (i.e. deployment) module
npm-mirror-deps: npm-mirror-dir
	DEBUG=npm-mirror:SyncManager \
	npm-mirror --master $(NPM_MASTER) \
	--manifests $(CURRENT_PACKAGE)/package.json \
	--hostname $(NPM_MIRROR_HOST) --root $(NPM_MIRROR_PATH)

pip-mirror: pip-mirror-dir
	pip install -d $(PIP_MIRROR_PATH) -U \
	-r $(PIP_REQUIREMENTS) -i $(PIP_MASTER)

pip-mirror-deps: pip-mirror-dir
	pip install -d $(PIP_MIRROR_PATH) -U \
	-r $(CURRENT_PACKAGE)/requirements.txt

npm-mirror-dir:
	mkdir -p $(NPM_MIRROR_PATH)
pip-mirror-dir:
	mkdir -p $(PIP_MIRROR_PATH)
mirror-dirs: npm-mirror-dir pip-mirror-dir
mirror-deps: pip-mirror-deps npm-mirror-deps

