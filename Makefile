CURRENT_PACKAGE = $(PWD)
PARENT_PACKAGE = $(PWD)/..
BUILD_DIR = $(CURRENT_PACKAGE)/build
EXPORT_DIR = $(CURRENT_PACKAGE)/export

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

build-dir:
	test -d $(BUILD_DIR) || mkdir $(BUILD_DIR)
export-dir:
	test -d $(EXPORT_DIR) || mkdir $(EXPORT_DIR)

unpacked-virtualenv: build-dir pip-mirror-deps
	tar xvf $(PIP_MIRROR_PATH)/virtualenv-*.tar.* -C $(BUILD_DIR)
built-virtualenv: unpacked-virtualenv export-dir
	cp -rf $(BUILD_DIR)/virtualenv-* export/virtualenv

# Reserve the right to do more with this if we find that setuptools
# Doesn't work for something and we actually need distribute
# As has happened on another project
bootstrap-python: built-virtualenv

clean-npm-mirror:
	rm -Rf $(NPM_MIRROR_PATH)
clean-pip-mirror:
	rm -Rf $(PIP_MIRROR_PATH)
clean-mirrors: clean-npm-mirror clean-pip-mirror

clean:
	rm -Rf $(BUILD_DIR)

