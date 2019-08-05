#!/usr/bin/env bash
if [[ -x "/remote/anaconda_token" ]]; then
    . /remote/anaconda_token || true
fi

set -ex

# Function to retry functions that sometimes timeout or have flaky failures
retry () {
    $*  || (sleep 1 && $*) || (sleep 2 && $*) || (sleep 4 && $*) || (sleep 8 && $*)
}

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters. Pass cuda version"
    echo "CUDA version should be M.m with dot, e.g. '8.0' or 'cpu'"
    exit 1
fi
desired_cuda="$1"

export TORCHVISION_BUILD_VERSION="0.4.0.dev$(date "+%Y%m%d")"
export TORCHVISION_BUILD_NUMBER=1

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [[ -z "$WIN_PACKAGE_WORK_DIR" ]]; then
    WIN_PACKAGE_WORK_DIR="$(echo $(pwd -W) | tr '/' '\\')\\tmp_conda_$(date +%H%M%S)"
fi

if [[ "$OSTYPE" == "msys" ]]; then
    mkdir -p "$WIN_PACKAGE_WORK_DIR" || true
    vision_rootdir="$(realpath ${WIN_PACKAGE_WORK_DIR})/torchvision-src"
    git config --system core.longpaths true
else
    vision_rootdir="$(pwd)/torchvision-src"
fi

if [[ "$BRANCH" == "" ]]; then
  BRANCH=master
fi

if [[ ! -d "$vision_rootdir" ]]; then
    rm -rf "$vision_rootdir"
    git clone "https://github.com/pytorch/vision" "$vision_rootdir" -b "$BRANCH"
fi

export TORCHVISION_GITHUB_ROOT_DIR="$vision_rootdir"

cd "$SOURCE_DIR"

if [[ "$OSTYPE" == "msys" ]]; then
    export tmp_conda="${WIN_PACKAGE_WORK_DIR}\\conda"
    export miniconda_exe="${WIN_PACKAGE_WORK_DIR}\\miniconda.exe"
    rm -rf "$tmp_conda"
    rm -f "$miniconda_exe"
    curl -sSk https://repo.continuum.io/miniconda/Miniconda3-latest-Windows-x86_64.exe -o "$miniconda_exe"
    "$SOURCE_DIR/install_conda.bat" && rm "$miniconda_exe"
    pushd $tmp_conda
    export PATH="$(pwd):$(pwd)/Library/usr/bin:$(pwd)/Library/bin:$(pwd)/Scripts:$(pwd)/bin:$PATH"
    popd
    # We have to skip 3.17 because of the following bug.
    # https://github.com/conda/conda-build/issues/3285
    retry conda install -yq conda-build
fi

ANACONDA_USER=pytorch-nightly
conda config --set anaconda_upload no


if [[ "$desired_cuda" == 'cpu' ]]; then
    export CONDA_CPU_ONLY_FEATURE="    - cpuonly # [not osx]"
    export CONDA_CUDATOOLKIT_CONSTRAINT=""
    export CUDA_VERSION="None"
    export VERSION_MATCH="*+cpu"
else
    . ./switch_cuda_version.sh $desired_cuda
    export CONDA_CPU_ONLY_FEATURE=""
    if [[ "$desired_cuda" == "10.0" ]]; then
        export CONDA_CUDATOOLKIT_CONSTRAINT="    - cudatoolkit >=10.0,<10.1 # [not osx]"
        export VERSION_MATCH="*"
    elif [[ "$desired_cuda" == "9.0" ]]; then
        export CONDA_CUDATOOLKIT_CONSTRAINT="    - cudatoolkit >=9.0,<9.1 # [not osx]"
        export VERSION_MATCH="*+cu90"
    elif [[ "$desired_cuda" == "9.2" ]]; then
        export CONDA_CUDATOOLKIT_CONSTRAINT="    - cudatoolkit >=9.2,<9.3 # [not osx]"
        export VERSION_MATCH="*+cu92"
    else
        echo "unhandled desired_cuda: $desired_cuda"
        exit 1
    fi
fi



LATEST_PYTORCH_NIGHTLY_VERSION=$(conda search --json "pytorch[channel=$ANACONDA_USER]==$VERSION_MATCH" | python "$SOURCE_DIR/get-latest.py")
# NB: We must provide +cu90, etc. in the constraint here
# This relies on Conda NOT respecting PEP 440 and letting
# us do wildcards with local version specifiers, which empirically
# seemed to work on 4.7.10
export CONDA_PYTORCH_CONSTRAINT="    - pytorch ==${LATEST_PYTORCH_NIGHTLY_VERSION}"

if [[ "$OSTYPE" == "msys" ]]; then
    time conda build -c $ANACONDA_USER --no-anaconda-upload vs2017
else
    time conda build -c $ANACONDA_USER --no-anaconda-upload --python 2.7 torchvision
fi
time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.5 torchvision
time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.6 torchvision
time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.7 torchvision

set +e
