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
    mkdir "${OUTPUT_DIR}/deps"
    wget "http://download.savannah.gnu.org/releases/freetype/freetype-2.12.1.tar.gz" -O "${OUTPUT_DIR}/deps/freetype.tar.gz"
    mkdir "${OUTPUT_DIR}/deps/freetype"
    tar -xzf "${OUTPUT_DIR}/deps/freetype.tar.gz" -C "${OUTPUT_DIR}/deps/freetype"
    git clone -b "jdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-${OPENJDK_TAG_VERSION}" "https://github.com/openjdk/jdk${OPENJDK_VERSION}u.git" "${OUTPUT_DIR}/source"
}

build () {
    INSTALL_DIR="${PWD}/${OUTPUT_DIR}"
    FREETYPE_SRC="$(find "${INSTALL_DIR}/deps/freetype" -maxdepth 1 -mindepth 1 -iname 'freetype*')"

    pushd "${OUTPUT_DIR}/source"

    bash configure \
        --prefix="${INSTALL_DIR}/install" \
        --with-milestone="fcs" \
        --with-update-version="${OPENJDK_UPDATE_VERSION}" \
        --with-build-number="b${OPENJDK_BUILD_VERSION}" \
        --enable-unlimited-crypto \
        --with-extra-cflags="-Wno-error=nonnull -Wno-error=deprecated-declarations -Wno-error=stringop-overflow= -Wno-error=return-type -Wno-error=cpp -fno-lifetime-dse -fno-delete-null-pointer-checks -fno-exceptions -Wno-error=format-overflow=" \
        --with-extra-cxxflags="-fno-exceptions" \
        --with-vendor-name="${OPENJDK_VENDOR_NAME}" \
        --with-vendor-url="${OPENJDK_VENDOR_URL}" \
        --with-freetype-src="${FREETYPE_SRC}"
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

    zip "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jdk.zip" "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}"

    zip "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jre.zip" "openjdk${OPENJDK_VERSION}u${OPENJDK_UPDATE_VERSION}-jre"

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