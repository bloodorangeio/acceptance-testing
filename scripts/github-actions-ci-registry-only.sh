#!/bin/bash -ex
#
# Copyright The Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Install virtualenv
which virtualenv || true
pip3 install --user virtualenv
virtualenv --version
which virtualenv

rm -rf bin/
mkdir -p bin/
export PATH="${PWD}/bin:${HOME}/.local/bin:${PATH}"
export GITHUB_SHA="${GITHUB_SHA:-latest}"

# Build helm from source
which helm || true
mkdir -p /tmp/gopath/src/helm.sh
pushd /tmp/gopath/src/helm.sh
git clone https://github.com/bloodorangeio/helm.git -b hip-6-push
pushd helm/
GOPATH=/tmp/gopath make build
popd
popd
mv /tmp/gopath/src/helm.sh/helm/bin/helm bin/helm
helm version
which helm

export ROBOT_OUTPUT_DIR="${PWD}/acceptance-testing-reports/${GITHUB_SHA}"
rm -rf ${ROBOT_OUTPUT_DIR}
mkdir -p ${ROBOT_OUTPUT_DIR}
trap "rm -rf ${ROBOT_OUTPUT_DIR}/.venv/" EXIT

export ROBOT_RUN_TESTS=registries.robot
make acceptance
