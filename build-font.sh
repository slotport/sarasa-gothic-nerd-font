#! /bin/bash

set -u
set -e

SARASA_GOTHIC_URL=https://github.com/be5invis/Sarasa-Gothic/releases/download/v0.35.9/sarasa-gothic-ttf-0.35.9.7z
SARASA_GOTHIC_FILE=${SARASA_GOTHIC_URL##*/}
FONTFORGE_VERSION_MINIMAL=20190801
UNITETTC_URL=http://yozvox.web.fc2.com/unitettc.zip
UNITETTC_FILE=${UNITETTC_URL##*/}
if [[ -z ${UNITETTC:-} ]]; then
    UNITETTC=unitettc64
fi

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
    echo "install fontforge"
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

if type ${UNITETTC} >/dev/null 2>&1; then
    :
else
    echo "missing: unitettc64"
    echo "install unitettc64"
    echo "http://yozvox.web.fc2.com/556E697465545443.html"
    exit 1
fi

# ================================================================

if [[ ! -d nerd-fonts-master ]]; then
    wget -q https://github.com/ryanoasis/nerd-fonts/archive/refs/heads/master.tar.gz -O - | tar xzf -
    #git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git -b v2.1.0
fi

if [[ ! -f ${SARASA_GOTHIC_FILE} ]]; then
    wget -q ${SARASA_GOTHIC_URL}
fi

# unzip sarasa
if [[ ! -d sarasa ]]; then
    7za x -osarasa ${SARASA_GOTHIC_FILE} sarasa-fixed-j-regular.ttf sarasa-fixed-j-bold.ttf
fi

# apply patches to nerd font


mkdir -p phase1_patched
mkdir -p phase2_adjusted

FONTFILE_REGULAR='Sarasa Fixed J Nerd Font Complete.ttf'
FONTFILE_BOLD='Sarasa Fixed J Bold Nerd Font Complete.ttf'

if [[ ! -f phase1_patched/${FONTFILE_REGULAR} ]]; then
    cd nerd-fonts-master
    ls -l
    fontforge -script ./font-patcher \
              ../sarasa/sarasa-fixed-j-regular.ttf \
              --quiet \
              --careful \
              --complete
    mv "${FONTFILE_REGULAR}" "../phase1_patched/${FONTFILE_REGULAR}"
    cd ..
else
    echo "already exist: 'phase1_patched/${FONTFILE_REGULAR}'"
fi

if [[ ! -f phase1_patched/${FONTFILE_BOLD} ]]; then
    cd nerd-fonts-master
    ls -l
    fontforge -script ./font-patcher \
              ../sarasa/sarasa-fixed-j-bold.ttf \
              --quiet \
              --careful \
              --complete
    mv "${FONTFILE_BOLD}" "../phase1_patched/${FONTFILE_BOLD}"
    cd ..
else
    echo "already exist: 'phase1_patched/${FONTFILE_BOLD}'"
fi

cd phase2_adjusted
ttx -ft 'OS/2' "../phase1_patched/${FONTFILE_REGULAR}"
mv "../phase1_patched/${FONTFILE_REGULAR%.ttf}.ttx" .
sed -i 's@<xAvgCharWidth value=".*"/>@<xAvgCharWidth value="500"/>@' "${FONTFILE_REGULAR%.ttf}.ttx"
cp "../phase1_patched/${FONTFILE_REGULAR}" .
ttx -fm "${FONTFILE_REGULAR}" "${FONTFILE_REGULAR%.ttf}.ttx"

ttx -ft 'OS/2' "../phase1_patched/${FONTFILE_BOLD}"
mv "../phase1_patched/${FONTFILE_BOLD%.ttf}.ttx" .
sed -i 's@<xAvgCharWidth value=".*"/>@<xAvgCharWidth value="500"/>@' "${FONTFILE_BOLD%.ttf}.ttx"
cp "../phase1_patched/${FONTFILE_BOLD}" .
ttx -fm "${FONTFILE_BOLD}" "${FONTFILE_BOLD%.ttf}.ttx"
cd ..

${UNITETTC} ./SarasaFixedJNerdFont.ttc "phase2_adjusted/${FONTFILE_REGULAR}" "phase2_adjusted/${FONTFILE_BOLD}"

echo generated ./SarasaFixedJNerdFont.ttc