---
name: laravel
description: Best practices in Laravel for use in this project
---

# When to use
Always when you edit or create a file in the `src` directory

## Laravel rules
Laravel version in this project - 13

Key Principles
- Write concise, technical responses with accurate PHP examples.
- Follow Laravel best practices and conventions.
- Use object-oriented programming with a focus on SOLID principles.
- Prefer iteration and modularization over duplication.
- Use descriptive variable and method names.
- Use lowercase with dashes for directories (e.g., app/Http/Controllers).
- Favor dependency injection and service containers.
- Always use type hinting in the parameters of the method
- Always use type hinting in the return values

PHP/Laravel
- Use PHP 8.4+ features when appropriate (e.g., typed properties, match expressions).
- Follow PSR-12 coding standards.
- Use strict typing: declare(strict_types=1);
- Utilize Laravel's built-in features and helpers when possible.
- File structure: Follow Laravel's directory structure and naming conventions.
- Implement proper error handling and logging:
- Use Laravel's exception handling and logging features.
- Create custom exceptions when necessary.
- Use try-catch blocks for expected exceptions.
- Use Laravel's validation features for form and request validation.
- Implement middleware for request filtering and modification.
- Utilize Laravel's Eloquent ORM for database interactions.
- Use Laravel's query builder for complex database queries.
- Implement proper database migrations and seeders.

Dependencies
- Laravel (latest stable version)
- Composer for dependency management

Laravel Best Practices
- Use Eloquent ORM instead of raw SQL queries when possible.
- Implement Repository pattern for data access layer.
- Use Laravel's built-in authentication and authorization features.
- Utilize Laravel's caching mechanisms for improved performance.
- Implement job queues for long-running tasks.
- Use Laravel's built-in testing tools (PHPUnit, Dusk) for unit and feature tests.
- Implement API versioning for public APIs.
- Use Laravel's localization features for multi-language support.
- Implement proper CSRF protection and security measures.
- Implement proper database indexing for improved query performance.
- Use Laravel's built-in pagination features.
- Implement proper error logging and monitoring.

Key Conventions
1. Follow Laravel's MVC architecture.
2. Use Laravel's routing system for defining application endpoints.
3. Implement proper request validation using Form Requests.
4. Use Laravel's Blade templating engine for views.
5. Implement proper database relationships using Eloquent.
6. Use Laravel's built-in authentication scaffolding.
7. Implement proper API resource transformations.
8. Use Laravel's event and listener system for decoupled code.
9. Implement proper database transactions for data integrity.
10. Use Laravel's built-in scheduling features for recurring tasks.

Artisan Commands
- Names: kebab-case (`delete-old-records`)
- Always provide feedback (`$this->comment('All ok!')`)
- Show progress for loops, summary at end
- Put output BEFORE processing item (easier debugging):
  ```php
  $items->each(function(Item $item) {
      $this->info("Processing item id `{$item->id}`...");
      $this->processItem($item);
  });

  $this->comment("Processed {$items->count()} items.");
  ```

API Routing
- Use plural resource names: `/errors`
- Use kebab-case: `/error-occurrences`
- Limit deep nesting for simplicity:
  ```
  /error-occurrences/1
  /errors/1/occurrences
  ```

Naming Conventions
- **Classes**: PascalCase (`UserController`, `OrderStatus`)
- **Methods/Variables**: camelCase (`getUserName`, `$firstName`)
- **Routes**: kebab-case (`/open-source`, `/user-profile`)
- **Config files**: snake_case (`pdf_generator.php`)
- **Config keys**: snake_case (`chrome_path`)
- **Artisan commands**: kebab-case (`php artisan delete-old-records`)

Project Specifics:
- Always use generics in models for relationships, example:
```php
/** @return BelongsTo<User, $this> */
public function user(): BelongsTo
{
    return $this->belongsTo(User::class, '<user_fk>');
}

/** @return BelongsTo<Status, $this> */
public function status(): BelongsTo
{
    return $this->belongsTo(Status::class, '<status_fk>');
}

/** @return HasOne<Profile, $this> */
public function profile(): HasOne
{
    return $this->hasOne(Profile::class, '<model_fk>');
}

/** @return HasMany<Comment, $this> */
public function comments(): HasMany
{
    return $this->hasMany(Comment::class, '<model_fk>');
}
// and other relationships
```
- For single-line annotations, always write them on one line.
- Once you've created the model, run `make ide-helper` to add doc blocks to the model
- After you have changed the files, check it `make check`
