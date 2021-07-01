#!/bin/bash

: "${TESTS:=$(echo tests/*_test.sh)}"

# shellcheck disable=SC1091
source /etc/profile.d/libvirt-uri.sh

./delete-cluster.sh || exit 1

test_failed=0
for file in $TESTS; do
  AGENT=$(echo "$file" | grep -oP '(?<=/).+(?=\_)')
  export AGENT=$AGENT

  if [[ "$AGENT" == "fence_scsi" ]]; then
    ./setup-cluster.sh --iscsi
  else
    ./setup-cluster.sh
  fi

  if ! bash "$file"; then
    test_failed=1
  fi
  ./delete-cluster.sh
done

if [ $test_failed -eq 1 ]; then
  echo -e "\033[0;31mThere are failing tests\033[0m"
  exit 3
fi

echo -e "\033[0;32mAll tests successfully passed!\033[0m"