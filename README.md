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
