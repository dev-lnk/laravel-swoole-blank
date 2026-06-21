---
name: php-unit
description: Rules for writing php tests in phpunit
---

# PHP Unit

## When to use
If you create or edit files in src/tests directory

## Description
This rules only for PhpUnit tests

## Rules
- This rules only for PhpUnit tests
- Dont write comment in tests
- Write the tests only on what you were told, you do not need to do extra work
- In tests, all dependencies are created through resolve: `resolve(UserRepositoryInterface::class)`
- Add php doc block for resolve objects /** @var UserRepositoryInterface $userRepository */
- Test run from: `make test`
- IMPORTANT!!! In factories use createOne() method instead of create()
- IMPORTANT!!! In factories use makeOne() method instead of make()
- If you use createOne or makeOne, no need to use docblock var
- IMPORTANT!!! After everything is done and all tests have passed, you should run the `make check` check and fix phpstan errors if there are any. Next, run only checks using phpstan after the fix