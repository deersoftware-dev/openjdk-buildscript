# OpenJDK version // 8, 11, 17
OPENJDK_VERSION="11"
# Update version for OpenJDK // 332 (OpenJDK 8), 0.15 (OpenJDK 11), 0.3 (OpenJDK 17)
OPENJDK_UPDATE_VERSION="0.15"
# Tag version for OpenJDK
OPENJDK_TAG_VERSION="ga"
# Build version for OpenJDK // 09 (OpenJDK 8), 10 (OpenJDK 11), 7 (OpenJDK 17) 
OPENJDK_BUILD_VERSION="10"
# OpenJDK vendor name
OPENJDK_VENDOR_NAME="DeerSoftware"
# OpenJDK vendor URL
OPENJDK_VENDOR_URL="www.deersoftware.dev"

OUTPUT_DIR="output/openjdk${OPENJDK_VERSION}"

download_source () {
    mkdir -p "${OUTPUT_DIR}"
    git clone -b "jdk-${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-${OPENJDK_TAG_VERSION}" "https://github.com/openjdk/jdk${OPENJDK_VERSION}u.git" "${OUTPUT_DIR}/source"
}

build () {
    pushd "${OUTPUT_DIR}/source"
    
    bash configure \
        --with-version-build="${OPENJDK_BUILD_VERSION}" \
        --with-version-pre="" \
        --with-version-opt="" \
        --with-extra-cflags="-fcommon" \
        --with-extra-cxxflags="-fcommon" \
        --with-jvm-features=zgc \
        --enable-unlimited-crypto \
        --disable-warnings-as-errors \
        --with-vendor-name="${OPENJDK_VENDOR_NAME}" \
        --with-vendor-url="${OPENJDK_VENDOR_URL}"
    make images legacy-jre-image

    find "build" -maxdepth 1 -iname 'linux-*' -exec cp -r "{}/images/jdk" "../openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}" \;
    find "build" -maxdepth 1 -iname 'linux-*' -exec cp -r "{}/images/jre" "../openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-jre" \;

    popd
}

package () {
    pushd "${OUTPUT_DIR}"
    
    tar --gzip --owner=root --group=root -cf "openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-jdk.tar.gz" "openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}"
    tar --xz --owner=root --group=root -cf "openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-jdk.tar.xz" "openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}"

    tar --gzip --owner=root --group=root -cf  "openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-jre.tar.gz" "openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-jre"
    tar --xz --owner=root --group=root -cf "openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-jre.tar.xz" "openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-jre"

    find "openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-jre/lib" -iname 'libawt_xawt.*' -exec rm {} \;
    find "openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-jre/lib" -iname 'libjawt.*' -exec rm {} \;
    find "openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-jre/lib" -iname 'libjsound.*' -exec rm {} \;
    find "openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-jre/lib" -iname 'libsplashscreen.*' -exec rm {} \;

    tar --gzip --owner=root --group=root -cf "openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-jre_headless.tar.gz" "openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-jre"
    tar --xz --owner=root --group=root -cf "openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-jre_headless.tar.xz" "openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-jre"

    popd
}

if [ ! -d "${OUTPUT_DIR}/source" ]
then
    download_source
fi

if [ ! -d "${OUTPUT_DIR}/openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}" ] || [ ! -d "${OUTPUT_DIR}/openjdk${OPENJDK_VERSION}.${OPENJDK_UPDATE_VERSION}-jre" ]
then
    build
fi

package