EMSDK_VERSION ?= 3.1.14
QT_VERSION ?= 6.4.1

qt_branch = $(shell cut -d. -f 1,2 <<< $(QT_VERSION))

download_emsdk :
	curl -o emsdk-$(EMSDK_VERSION).tar.gz -L https://github.com/emscripten-core/emsdk/archive/refs/tags/$(EMSDK_VERSION).tar.gz

download_qt :
	curl -O -L https://download.qt.io/archive/qt/$(qt_branch)/$(QT_VERSION)/single/qt-everywhere-src-$(QT_VERSION).tar.xz

image :
	podman build --build-arg "EMSDK_VERSION=$(EMSDK_VERSION)" --build-arg "QT_VERSION=$(QT_VERSION)" -t qtwebasm:$(qt_branch) .
