EMSDK_VERSION ?= 3.1.25
QT_VERSION ?= 6.5.2

RUNTIME ?= podman

qt_branch = $(shell cut -d. -f 1,2 <<< $(QT_VERSION))

image : emsdk-$(EMSDK_VERSION).tar.gz qt-everywhere-src-$(QT_VERSION).tar.xz
	$(RUNTIME) build --build-arg "EMSDK_VERSION=$(EMSDK_VERSION)" --build-arg "QT_VERSION=$(QT_VERSION)" -f Containerfile -t qtwebasm:$(qt_branch) .

emsdk-$(EMSDK_VERSION).tar.gz :
	curl -o emsdk-$(EMSDK_VERSION).tar.gz -L https://github.com/emscripten-core/emsdk/archive/refs/tags/$(EMSDK_VERSION).tar.gz

qt-everywhere-src-$(QT_VERSION).tar.xz :
	curl -O -L https://download.qt.io/archive/qt/$(qt_branch)/$(QT_VERSION)/single/qt-everywhere-src-$(QT_VERSION).tar.xz

clean :
	rm emsdk-$(EMSDK_VERSION).tar.gz qt-everywhere-src-$(QT_VERSION).tar.xz
	$(RUNTIME) rmi qtwebasm:$(qt_branch)
