#!/usr/bin/env bash
tag="$1"; payload="$(cat)"
echo "=== $tag ===" >> /tmp/ragha-events.log
echo "$payload" | head -c 300 >> /tmp/ragha-events.log
echo "" >> /tmp/ragha-events.log
exit 0
