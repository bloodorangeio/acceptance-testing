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

*** Test Cases ***
Able to "helm registry login" to a registry
    Should pass  helm version

Able to "helm push" charts to a registry
    Should pass  helm version

Able to "helm pull" charts from a registry
    Should pass  helm version

Able to "helm install" using charts from a registry
    Should pass  helm version

Able to "helm upgrade" using charts from a registry
    Should pass  helm version

Able to "helm dep build" using charts from a registry
    Should pass  helm version

Able to "helm dep update" using charts from a registry
    Should pass  helm version

Able to "helm registry logout" from a registry
    Should pass  helm version
