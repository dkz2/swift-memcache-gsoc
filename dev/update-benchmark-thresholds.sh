#!/bin/bash
##===----------------------------------------------------------------------===##
##
## This source file is part of the SwiftNIO open source project
##
## Copyright (c) 2023 Apple Inc. and the SwiftNIO project authors
## Licensed under Apache License v2.0
##
## See LICENSE.txt for license information
## See CONTRIBUTORS.txt for the list of SwiftNIO project authors
##
## SPDX-License-Identifier: Apache-2.0
##
##===----------------------------------------------------------------------===##
##===----------------------------------------------------------------------===##
##
## This source file is part of the SwiftCertificates open source project
##
## Copyright (c) 2023 Apple Inc. and the SwiftCertificates project authors
## Licensed under Apache License v2.0
##
## See LICENSE.txt for license information
## See CONTRIBUTORS.txt for the list of SwiftCertificates project authors
##
## SPDX-License-Identifier: Apache-2.0
##
##===----------------------------------------------------------------------===##
##//===----------------------------------------------------------------------===//
##//
##// This source file is part of the swift-memcache-gsoc open source project
##//
##// Copyright (c) 2023 Apple Inc. and the swift-memcache-gsoc project authors
##// Licensed under Apache License v2.0
##//
##// See LICENSE.txt for license information
##// See CONTRIBUTORS.txt for the list of swift-memcache-gsoc project authors
##//
##// SPDX-License-Identifier: Apache-2.0
##//
##//===----------------------------------------------------------------------===//

set -eu
set -o pipefail

here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
target_repo=${2-"$here/.."}

for f in 57 58 59 510 -nightly; do
    echo "swift$f"

    docker_file=$(if [[ "$f" == "-nightly" ]]; then f=main; fi && ls "$target_repo/docker/docker-compose."*"$f"*".yaml")

    docker-compose -f docker/docker-compose.yaml -f $docker_file run update-benchmark-baseline
done
