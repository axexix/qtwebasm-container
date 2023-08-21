ARG UPSTREAM_TAG=38

FROM public.ecr.aws/docker/library/fedora:${UPSTREAM_TAG} as base

ARG     EMSDK_VERSION

RUN     dnf install -y cmake curl git ninja-build xz lbzip2 perl-English \
        && alternatives --install /usr/bin/python python /usr/bin/python3 1

RUN     useradd -U -s /bin/bash dev

USER    dev
WORKDIR /home/dev

COPY    emsdk-${EMSDK_VERSION}.tar.gz ./

RUN     tar -xf emsdk-${EMSDK_VERSION}.tar.gz                   && \
        cd emsdk-${EMSDK_VERSION}                               && \
        ./emsdk install ${EMSDK_VERSION}                        && \
        ./emsdk activate ${EMSDK_VERSION}

RUN     echo "source '/home/dev/emsdk-${EMSDK_VERSION}/emsdk_env.sh'" >> ${HOME}/.bash_profile


FROM    base AS qtbuild

ARG     QT_VERSION

USER    root
RUN     dnf groupinstall -y "C Development Tools and Libraries" \
        && dnf install -y clang-devel llvm-devel

USER    dev

COPY    qt-everywhere-src-${QT_VERSION}.tar.xz ./

RUN     tar -xf qt-everywhere-src-${QT_VERSION}.tar.xz

RUN     bash -lc '\
        mkdir qt6 qt6-build &&                          \
        cd qt6-build                                 && \
        ../qt-everywhere-src-${QT_VERSION}/configure    \
        -opensource                                     \
        -prefix /home/dev/qt6                           \
        --confirm-license                               \
        -submodules qttools,qtshadertools               \
        -no-opengl                                   && \
        cmake --build . --parallel                   && \
        cmake --install .'

RUN     bash -lc '\
        mkdir qt6-wasm qt6-build-wasm &&                          \
        cd qt6-build-wasm                            && \
        ../qt-everywhere-src-${QT_VERSION}/configure    \
        -qt-host-path /home/dev/qt6                     \
        -platform wasm-emscripten                       \
        -submodules qtbase,qtdeclarative,qtimageformats,qtsvg,qtwebsockets,qttools \
        -opensource                                     \
        -prefix /home/dev/qt6-wasm                      \
        --confirm-license                            && \
        cmake --build . --parallel                   && \
        cmake --install .'


FROM    base

COPY    --from=qtbuild /home/dev/qt6-wasm /home/dev/qt6-wasm
COPY    --from=qtbuild /home/dev/qt6 /home/dev/qt6
RUN     echo 'PATH="${PATH}:/home/dev/qt6-wasm/bin"' >> ${HOME}/.bash_profile

CMD     ["bash", "-l"]
