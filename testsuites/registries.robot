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
    Should fail  echo fakepassword123 | helm registry login %{REGISTRY_ROOT_URL} -u %{REGISTRY_USERNAME} --password-stdin
    Should pass  set +x && echo %{REGISTRY_PASSWORD} | helm registry login %{REGISTRY_ROOT_URL} -u %{REGISTRY_USERNAME} --password-stdin

Able to "helm push" charts to a registry
    Should pass  helm package testdata/charts/nginx
    #Should fail  helm push nginx-0.1.0.tgz oci://%{REGISTRY_ROOT_URL}/badroot/%{REGISTRY_NAMESPACE}
    Should pass  helm push nginx-0.1.0.tgz oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}

Able to "helm pull" charts from a registry
    Should fail  rm -f nginx-0.1.0.tgz && ls nginx-0.1.0.tgz
    Should pass  helm pull oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.0
    Should pass  ls nginx-0.1.0.tgz

Able to "helm install" using charts from a registry
    Should fail  rm -f nginx-0.1.0.tgz && ls nginx-0.1.0.tgz
    Should pass  helm install nginx oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.0 --dry-run --debug

Able to "helm upgrade" using charts from a registry
    Should fail  rm -f nginx-0.1.0.tgz && ls nginx-0.1.0.tgz
    Should pass  helm upgrade nginx oci://%{REGISTRY_ROOT_URL}/%{REGISTRY_NAMESPACE}/nginx --version 0.1.0 --dry-run --debug

Able to "helm dep build" using charts from a registry
    Should pass  helm version

Able to "helm dep update" using charts from a registry
    Should pass  helm version

Able to "helm registry logout" from a registry
    Should pass  helm registry logout %{REGISTRY_ROOT_URL}

*** Keyword ***
Check for required environment variables
    Get Environment Variable  REGISTRY_ROOT_URL
    Get Environment Variable  REGISTRY_NAMESPACE
    Get Environment Variable  REGISTRY_USERNAME
    Get Environment Variable  REGISTRY_PASSWORD

