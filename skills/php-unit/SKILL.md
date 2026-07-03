---
name: php-unit
description: Rules for writing PHP tests with PHPUnit
---

# PHP Unit

## When to use
If you create or edit files in the `src/tests` directory.

## Description
These rules apply only to PHPUnit tests.

## Rules
- These rules apply only to PHPUnit tests.
- Do not write comments in tests.
- Write tests only for what you were asked to test; do not do extra work.
- In tests, create all dependencies through `resolve()`: `resolve(UserRepositoryInterface::class)`.
- Add a PHPDoc block for resolved objects: `/** @var UserRepositoryInterface $userRepository */`.
- Do not use `self::assert<Method>` in tests; use `$this->assert<Method>`.
- Run tests with `make test`.
- IMPORTANT!!! In factories, use the `createOne()` method instead of `create()`.
- IMPORTANT!!! In factories, use the `makeOne()` method instead of `make()`.
- If you use `createOne()` or `makeOne()`, no PHPDoc `@var` block is needed.
- IMPORTANT!!! After all work is done and all tests have passed, run `make check` and fix any PHPStan errors. After fixing them, run only the PHPStan checks.
