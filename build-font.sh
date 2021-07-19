#! /bin/bash

set -u
set -e

SARASA_GOTHIC_URL=https://github.com/be5invis/Sarasa-Gothic/releases/download/v0.32.10/sarasa-gothic-ttf-0.32.10.7z
SARASA_GOTHIC_FILE=${SARASA_GOTHIC_URL##*/}
FONTFORGE_VERSION_MINIMAL=20190801
UNITETTC_URL=http://yozvox.web.fc2.com/unitettc.zip
UNITETTC_FILE=${UNITETTC_URL##*/}

# ================================================================
# precondition check
# ================================================================

if type 7za >/dev/null 2>&1; then
    :
else
    echo "missing: 7za"
    exit 1
fi

if type fontforge >/dev/null 2>&1; then
    :
else
    echo "missing: fontforge"
    echo "install ffontforge"
    exit 1
fi

FONTFORGE_VERSION=$(fontforge --version 2>&1 | grep Version: | sed -E 's/^\s+Version:\s+//')
if [[ ${FONTFORGE_VERSION} -lt ${FONTFORGE_VERSION_MINIMAL} ]]; then
    echo "fontforge must be equal or newer than 20200314"
    exit 1
fi

if type ttx >/dev/null 2>&1; then
    :
else
    echo "missing: ttx"
    echo "install fonttools"
    exit 1
fi

if type unitettc64 >/dev/null 2>&1; then
    :
else
    echo "missing: unitettc64"
    echo "install unitettc64"
    echo "http://yozvox.web.fc2.com/556E697465545443.html"
    exit 1
fi

# ================================================================

if [[ ! -d nerd-fonts ]]; then
    git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git -b v2.1.0
fi

if [[ ! -f ${SARASA_GOTHIC_FILE} ]]; then
    wget ${SARASA_GOTHIC_URL}
fi

if [[ ! -d sarasa ]]; then
    7za x -osarasa ${SARASA_GOTHIC_FILE} sarasa-fixed-j-regular.ttf sarasa-fixed-j-bold.ttf
fi

cd nerd-fonts

FONTFILE_REGULAR='Sarasa Fixed J Nerd Font Complete.ttf'
FONTFILE_BOLD='Sarasa Fixed J Bold Nerd Font Complete.ttf'

if [[ ! -f ${FONTFILE_REGULAR} ]]; then
    fontforge -script font-patcher \
              ../sarasa/sarasa-fixed-j-regular.ttf \
              --quiet \
              --careful \
              --complete
else
    echo "already exist: '${FONTFILE_REGULAR}'"
fi

if [[ ! -f ${FONTFILE_BOLD} ]]; then
    fontforge -script font-patcher \
              ../sarasa/sarasa-fixed-j-bold.ttf \
              --quiet \
              --careful \
              --complete
else
    echo "already exist: '${FONTFILE_BOLD}'"
fi

ttx -ft 'OS/2' "${FONTFILE_REGULAR}"
sed -i 's@<xAvgCharWidth value=".*"/>@<xAvgCharWidth value="500"/>@' "${FONTFILE_REGULAR%.ttf}.ttx"
ttx -fm "${FONTFILE_REGULAR}" "${FONTFILE_REGULAR%.ttf}.ttx"

ttx -ft 'OS/2' "${FONTFILE_BOLD}"
sed -i 's@<xAvgCharWidth value=".*"/>@<xAvgCharWidth value="500"/>@' "${FONTFILE_BOLD%.ttf}.ttx"
ttx -fm "${FONTFILE_BOLD}" "${FONTFILE_BOLD%.ttf}.ttx"

unitettc64 ../SarasaFixedJNerdFont.ttc "${FONTFILE_REGULAR}" "${FONTFILE_BOLD}"
