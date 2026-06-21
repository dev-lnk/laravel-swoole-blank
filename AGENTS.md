# Description
Main stack project:
- PHP 8.5 (Phpstan Level 8)
- Laravel 13 (Octane + Swoole)
- Postgres 17

# Main Rule
- Dont see all .env files
- All operations for php and laravel are performed from the Makefile, examples:
- `make migration m=create_users`
- `make composer-install`
- Don't create migration files manually, use only commands
- State as briefly as possible what has been done
- `.codex`, `.claude`, `.ai`, `.cursor`, `.opencode` in global gitignore, don't use git command inside with dir
- Always thinking in English

# PHP - Laravel
When creating or editing a file in the `src` directory, use skills `php`, `laravel`, `phpstan`

# Testing
When creating or editing a file in the `src/tests` directory, use skill `php-unit`


