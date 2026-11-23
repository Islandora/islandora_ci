# Islandora CI

Drupal docker images to easily run linters and phpunit tests for various combinations of Drupal and PHP.

e.g. to test the islandora module in Drupal 11.3 in php 8.3 you can run

```bash
ENABLE_MODULES=islandora
docker run --rm \
  --volume $(pwd):/var/www/drupal/web/modules/contrib/$MODULE:r \
  --env ENABLE_MODULES \
 ghcr.io/islandora/ci:11.3-php8.3
```

## Settings

You can pass some environment variables to the docker image

| Env Var Name       | Default | Description                                                                                          |
|------------------- | ------- | ---------------------------------------------------------------------------------------------------- |
| `ENABLE_MODULES`   |         | The name of the module to enable (e.g. ENABLE_MODULES=islandora)                                     |
| `LINT`             | `1`     | 1 or 0 - whether to run code sniffer with `Drupal` standard on the `ENABLE_MODULES` codebase         |
| `DRUPAL_PRACTICE`  | `1`     | 1 or 0 - whether to run code sniffer with `DrupalPractice` standard on the `ENABLE_MODULES` codebase |
| `TEST_SUITE`       |         | phpunit testsuite to run. Blank value runs all the tests.                                            |

## Temporary Islandora 2.x dependency workaround

The legacy Flysystem backport is enabled by default for Islandora 2.x CI jobs.
The entrypoint installs Composer Patches 2, pins League Flysystem to 1.1.10,
applies the bundled malformed UTF-8 backport, and verifies that malformed paths
are rejected before installing module dependencies. Patch failures stop the job.
Only advisory `PKSA-w9tt-7782-78jx` is ignored, with the patch recorded as the
reason. Other advisory blocking remains enabled. The older RCE advisory does
not affect 1.1.10.

For Flysystem 3 jobs, disable the backport in the CI container environment:

```yaml
LEGACY_FLYSYSTEM_PATCH: 0
```

For `docker run`, pass `--env LEGACY_FLYSYSTEM_PATCH=0` to disable it.
Flysystem 3 jobs must disable this workaround because it pins Flysystem 1.1.10.
This changes only the CI project, not installation requirements or security
policy for downstream sites.

Backport reference: <https://github.com/advisories/GHSA-cxf4-7mrp-vvpr>.
