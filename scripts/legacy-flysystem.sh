#!/usr/bin/env bash
# Temporary backport for Islandora 2.x CI only.
set -eou pipefail

composer config --no-plugins allow-plugins.cweagans/composer-patches true
composer require --no-interaction 'cweagans/composer-patches:^2.0'

jq '
  .require["league/flysystem"] = "1.1.10" |
  .config.audit.ignore["PKSA-w9tt-7782-78jx"] =
    "Backported malformed UTF-8 fix in patches/flysystem-1.1.10-utf8.patch" |
  .extra.patches["league/flysystem"] = [{
    description: "Reject malformed UTF-8 paths (CVE-2026-102601)",
    url: "patches/flysystem-1.1.10-utf8.patch",
    depth: 1
  }]
' composer.json > composer.json.tmp
mv composer.json.tmp composer.json
composer patches-relock --no-interaction
composer update league/flysystem --with-dependencies --no-interaction

# Verify the patched behavior before permitting any module tests to run.
# Keep PHP variables literal so the shell does not expand them.
# shellcheck disable=SC2016
php -r '
require "vendor/autoload.php";
if (League\Flysystem\Util::normalizePath("valid/path.txt") !== "valid/path.txt") {
    throw new RuntimeException("Valid path normalization failed");
}
try {
    League\Flysystem\Util::normalizePath("invalid\x80\x1b/path.txt");
} catch (League\Flysystem\CorruptedPathDetected $e) {
    exit(0);
}
throw new RuntimeException("Flysystem malformed UTF-8 backport is not active");
'
