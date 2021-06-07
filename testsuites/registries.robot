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

*** Settings ***
Documentation     Verify helm works properly with registries.
...
Library           OperatingSystem
Library           ../lib/Sh.py
Suite Setup       Check for required environment variables

*** Test Cases ***
Able to "helm registry login" to a registry
    Should fail and contain output  unset HELM_EXPERIMENTAL_OCI && set +x && echo %{REGISTRY_PASSWORD} | helm registry login %{REGISTRY_ROOT_URL} -u %{REGISTRY_USERNAME} --password-stdin  Please set HELM_EXPERIMENTAL_OCI=1
    Should fail  echo fakepassword123 | helm registry login %{REGISTRY_ROOT_URL} -u %{REGISTRY_USERNAME} --password-stdin
    Should pass  set +x && echo %{REGISTRY_PASSWORD} | helm registry login %{REGISTRY_ROOT_URL} -u %{REGISTRY_USERNAME} --password-stdin

Able to "helm push" charts to a registry
    Should pass  helm package testdata/charts/nginx
    Should fail and contain output  unset HELM_EXPERIMENTAL_OCI && helm push nginx-0.1.0.tgz oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}  Please set HELM_EXPERIMENTAL_OCI=1
    Should fail  helm push nginx-0.1.0.tgz oci://%{REGISTRY_ROOT_URL}/badroot/%{REGISTRY_NAMESPACE}
    Should pass  helm push nginx-0.1.0.tgz oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}
    Should pass  helm package testdata/charts/nginx --version 0.1.1
    Should pass  helm push nginx-0.1.1.tgz oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}

Able to "helm push" charts to a registry (with prov)
    Should pass  rm -f nginx-0.1.2.tgz nginx-0.1.2.tgz.prov
    Should pass  helm package testdata/charts/nginx --version 0.1.2 --sign --key helm-test --keyring testdata/pgp/helm-test-key.secret
    Should pass  ls nginx-0.1.2.tgz nginx-0.1.2.tgz.prov
    Should pass  helm verify --keyring testdata/pgp/helm-test-key.secret nginx-0.1.2.tgz
    Should fail and contain output  unset HELM_EXPERIMENTAL_OCI && helm push --with-prov nginx-0.1.2.tgz oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}  Please set HELM_EXPERIMENTAL_OCI=1
    Should pass  helm push --with-prov nginx-0.1.2.tgz oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}

Able to "helm pull" charts from a registry
    Should fail and contain output  unset HELM_EXPERIMENTAL_OCI && helm pull oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.1  Please set HELM_EXPERIMENTAL_OCI=1
    Should fail  helm pull oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.2.0
    Should fail  ls nginx-0.2.0.tgz
    Should fail  rm -f nginx-0.1.1.tgz && ls nginx-0.1.1.tgz
    Should pass  helm pull oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.1
    Should pass  ls nginx-0.1.1.tgz
    Should fail  rm -f nginx-0.1.2.tgz nginx-0.1.2.tgz.prov && ls nginx-0.1.2.tgz nginx-0.1.2.tgz.prov
    Should pass  helm pull oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.2
    Should pass  ls nginx-0.1.2.tgz
    Should fail  ls nginx-0.1.2.tgz.prov
    Should fail  rm -f nginx-0.1.0.tgz && ls nginx-0.1.0.tgz
    Should pass  helm pull oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.0
    Should pass  ls nginx-0.1.0.tgz

Able to "helm pull" charts from a registry (with prov)
    Should fail  rm -f nginx-0.1.0.tgz nginx-0.1.0.tgz.prov && ls nginx-0.1.0.tgz nginx-0.1.0.tgz.prov
    Should fail  helm pull --verify --keyring testdata/pgp/helm-test-key.secret oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.0
    Should pass  ls nginx-0.1.0.tgz
    Should fail  ls nginx-0.1.0.tgz.prov
    Should fail  rm -f nginx-0.1.2.tgz nginx-0.1.2.tgz.prov && ls nginx-0.1.2.tgz nginx-0.1.2.tgz.prov
    Should fail and contain output  unset HELM_EXPERIMENTAL_OCI && helm pull --verify --keyring testdata/pgp/helm-test-key.secret oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.2  Please set HELM_EXPERIMENTAL_OCI=1
    Should pass  helm pull --verify --keyring testdata/pgp/helm-test-key.secret oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.2
    Should pass  ls nginx-0.1.2.tgz nginx-0.1.2.tgz.prov
    Should pass  helm verify --keyring testdata/pgp/helm-test-key.secret nginx-0.1.2.tgz

Able to "helm show" using charts from a registry
    Should fail and contain output  unset HELM_EXPERIMENTAL_OCI && helm show all oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.0  Please set HELM_EXPERIMENTAL_OCI=1
    Should pass  helm show all oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.0
    Should fail  helm show all oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.2.0

Able to "helm template" using charts from a registry
    Should fail and contain output  unset HELM_EXPERIMENTAL_OCI && helm template nginx oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.0  Please set HELM_EXPERIMENTAL_OCI=1
    Should pass  helm template nginx oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.0
    Should fail  helm template nginx oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.2.0

Able to "helm install" using charts from a registry
    Should fail and contain output  unset HELM_EXPERIMENTAL_OCI && helm install nginx oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.0 --dry-run  Please set HELM_EXPERIMENTAL_OCI=1
    Should pass or contain output  helm install nginx oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.0 --dry-run  Kubernetes cluster unreachable
    Should fail and not contain output  helm install nginx oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.2.0 --dry-run  Kubernetes cluster unreachable

Able to "helm upgrade" using charts from a registry
    Should fail and contain output  unset HELM_EXPERIMENTAL_OCI && helm upgrade --install nginx oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.1 --dry-run  Please set HELM_EXPERIMENTAL_OCI=1
    Should pass or contain output  helm upgrade --install nginx oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.1 --dry-run  Kubernetes cluster unreachable
    # TODO: helm upgrade introspects cluster, so hard to test without one
    #Should fail and not contain output  helm upgrade --install nginx oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.2.0 --dry-run  Kubernetes cluster unreachable

Able to "helm dep build" using charts from a registry
    Should pass  rm -rf testdata/charts/mychart && helm create testdata/charts/mychart
    Should fail  ls testdata/charts/mychart/charts/nginx-0.1.0.tgz
    Should pass  echo "dependencies:" >> testdata/charts/mychart/Chart.yaml
    Should pass  echo "- {name: nginx, version: 0.1.0, repository: oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}}" >> testdata/charts/mychart/Chart.yaml
    Should fail and contain output  unset HELM_EXPERIMENTAL_OCI && helm dep build testdata/charts/mychart  Please set HELM_EXPERIMENTAL_OCI=1
    Should pass  helm dep build testdata/charts/mychart
    Should pass  ls testdata/charts/mychart/charts/nginx-0.1.0.tgz
    Should pass  rm -rf testdata/charts/mychart/charts
    Should pass  helm dep build testdata/charts/mychart
    Should pass  ls testdata/charts/mychart/charts/nginx-0.1.0.tgz

Able to "helm dep update" using charts from a registry
    Should pass  cat testdata/charts/mychart/Chart.yaml | sed 's/name: nginx, version: 0\.1\.0/name: nginx, version: 0\.1\.1/' > testdata/charts/mychart/Chart.yaml.tmp
    Should pass  mv testdata/charts/mychart/Chart.yaml.tmp testdata/charts/mychart/Chart.yaml
    Should pass  cat testdata/charts/mychart/Chart.yaml
    Should fail and contain output  unset HELM_EXPERIMENTAL_OCI && helm dep update testdata/charts/mychart  Please set HELM_EXPERIMENTAL_OCI=1
    Should pass  helm dep update testdata/charts/mychart
    Should fail  ls testdata/charts/mychart/charts/nginx-0.1.0.tgz
    Should pass  ls testdata/charts/mychart/charts/nginx-0.1.1.tgz

Able to "helm registry logout" from a registry
    Should fail and contain output  unset HELM_EXPERIMENTAL_OCI && helm registry logout %{REGISTRY_ROOT_URL}  Please set HELM_EXPERIMENTAL_OCI=1
    Should pass  helm registry logout %{REGISTRY_ROOT_URL}

*** Keyword ***
Check for required environment variables
    Get Environment Variable  REGISTRY_ROOT_URL
    Get Environment Variable  REGISTRY_NAMESPACE
    Get Environment Variable  REGISTRY_USERNAME
    Get Environment Variable  REGISTRY_PASSWORD
    Set Environment Variable  KUBECONFIG  testdata/kube/empty-kubeconfig.yaml
    Set Environment Variable  HELM_EXPERIMENTAL_OCI  1
