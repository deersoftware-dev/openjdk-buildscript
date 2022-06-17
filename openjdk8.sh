# OpenJDK version // 8, 17
OPENJDK_VERSION="8"
# Update version for OpenJDK // 332 (OpenJDK 8), 0.3 (OpenJDK 17)
OPENJDK_UPDATE_VERSION="332"
# Tag version for OpenJDK
OPENJDK_TAG_VERSION="ga"
# Build version for OpenJDK // 09 (OpenJDK 8), 7 (OpenJDK 17) 
OPENJDK_BUILD_VERSION="09"
# OpenJDK vendor name
OPENJDK_VENDOR_NAME="DeerSoftware"
# OpenJDK vendor URL
OPENJDK_VENDOR_URL="www.deersoftware.dev"

OUTPUT_DIR="output/openjdk${OPENJDK_VERSION}"

download_source () {
    mkdir -p "${OUTPUT_DIR}"
    git clone -b "jdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-${OPENJDK_TAG_VERSION}" "https://github.com/openjdk/jdk${OPENJDK_VERSION}u.git" "${OUTPUT_DIR}/source"
}

build () {
    INSTALL_DIR="${PWD}/${OUTPUT_DIR}"

    cp openjdk8_gcc11.patch "${OUTPUT_DIR}/source/gcc11.patch"

    pushd "${OUTPUT_DIR}/source"
    patch -Np1 -i gcc11.patch

    bash configure \
        --prefix="${INSTALL_DIR}/install" \
        --with-milestone="fcs" \
        --with-update-version="${OPENJDK_UPDATE_VERSION}" \
        --with-build-number="b${OPENJDK_BUILD_VERSION}" \
        --enable-unlimited-crypto \
        --with-extra-cflags="-Wno-error=nonnull -Wno-error=deprecated-declarations -Wno-error=stringop-overflow= -Wno-error=return-type -Wno-error=cpp -fno-lifetime-dse -fno-delete-null-pointer-checks -fcommon -fno-exceptions -Wno-error=format-overflow=" \
        --with-extra-cxxflags="-fcommon -fno-exceptions" \
        --with-vendor-name="${OPENJDK_VENDOR_NAME}" \
        --with-vendor-url="${OPENJDK_VENDOR_URL}" \
        $@
    make
    make install

    find "${INSTALL_DIR}/install" -iname '*.diz' -exec rm {} \;
    find "${INSTALL_DIR}/install" -iname '*.debuginfo' -exec rm {} \;

    find "${INSTALL_DIR}/install/jvm" -maxdepth 1 -iname 'openjdk-*' -exec cp -r "{}" "${INSTALL_DIR}/openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}" \;
    find "${INSTALL_DIR}/install/jvm" -maxdepth 1 -iname 'openjdk-*' -exec cp -r "{}/jre" "${INSTALL_DIR}/openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jre" \;

    popd
}

package () {
    pushd "${OUTPUT_DIR}"

    tar --gzip --owner=root --group=root -cf "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jdk.tar.gz" "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}"
    tar --xz --owner=root --group=root -cf "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jdk.tar.xz" "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}"

    tar --gzip --owner=root --group=root -cf "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jre.tar.gz" "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jre"
    tar --xz --owner=root --group=root -cf "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jre.tar.xz" "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jre"

    rm "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jre/bin/policytool"
    find "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jre/lib" -iname 'libjsound.so' -exec rm {} \;
    find "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jre/lib" -iname 'libjsoundalsa.so' -exec rm {} \;
    find "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jre/lib" -iname 'libsplashscreen.so' -exec rm {} \;
    tar --gzip --owner=root --group=root -cf "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jre_headless.tar.gz" "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jre"
    tar --xz --owner=root --group=root -cf "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jre_headless.tar.xz" "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jre"

    popd
}

if [[ ! -d "${OUTPUT_DIR}/openjdk${OPENJDK_VERSION}/source" ]]
then
    download_source
fi

if [[ ! -d "${OUTPUT_DIR}/openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}" ]] || [[ ! -d "${OUTPUT_DIR}/openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jre" ]]
then
    build
fi

package