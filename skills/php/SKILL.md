---
name: php
description: Best practices in PHP for use in this project
---

# When to use
Always when you edit or create a file in the `src` directory

# PHP rules
Php version in this project - 8.5

## Clean Code Guidelines
Guidelines for writing clean, maintainable, and human-readable code. Apply these rules when writing or reviewing code to ensure consistency and quality.

## PHP Standards
- Use short nullable notation: `?string` not `string|null`
- Always specify `void` return types when methods return nothing

## Class Structure
- Use typed properties, not docblocks:
- Constructor property promotion when all properties can be promoted:
- Declare class properties in the constructor whenever possible
- All classes must be final readonly by default
- Abstract classes must contains abstract methods or final methods
## Features
- Use PHP features (php version is defined in composer.json file) when appropriate (e.g., typed properties, match expressions).
## Exceptions
- Create custom exceptions when necessary.
## PHPDocs
- Fill missing shaped array for all iterable types
- Never generate phpdocs for non existing variable
- Don't write comments unless asked.
- Analyze the existing PHPDocs and if it does not match the functionality then modify the existing PHPDocs
- Delete unnecessary comments, but not those that can be used for PHPStan analysis. If the short description is the same or very similar to the method or function name, delete it.
- Document iterables with generics:
  ```php
  /** @return Collection<int, User> */
  public function getUsers(): Collection
  ```
- Use one-line docblocks when possible: `/** @var string */`
- Most common type should be first in multi-type docblocks:
  ```php
  /** @var Collection|SomeWeirdVendor\Collection */
  ```
- For iterables, always specify key and value types:
  ```php
  /**
   * @param array<int, MyObject> $myArray
   * @param int $typedArgument
   */
  function someFunction(array $myArray, int $typedArgument) {}
  ```
- Use array shape notation for fixed keys, put each key on it's own line:
  ```php
  /** @return array{
     first: SomeClass,
     second: SomeClass
  } */
  ```
## Control Flow
- **Avoid else**: Use early returns instead of nested conditions
- **Separate conditions**: Prefer multiple if statements over compound conditions
- **Always use curly brackets** even for single statements
- **Ternary operators**: Each part on own line unless very short
## Strings & Formatting
- **String interpolation** over concatenation:
## Enums
- Use PascalCase for enum values:
## Validation
- Custom validation rules use snake_case:
```php
  Validator::extend('organisation_type', function ($attribute, $value) {
      return OrganisationType::isValid($value);
  });
```
### Configuration
- Files: kebab-case (`pdf-generator.php`)
- Keys: snake_case (`chrome_path`)
- Add service configs to `config/services.php`, don't create new files
- Use `config()` helper, avoid `env()` outside config files
## Constants Over Magic Numbers
- Replace hard-coded values with named constants
- Use descriptive constant names that explain the value's purpose
- Keep constants at the top of the file or in a dedicated constants file
## Meaningful Names
- Variables, functions, and classes should reveal their purpose
- Names should explain why something exists and how it's used
- Avoid abbreviations unless they're universally understood
- Set method and class names as camel case
## Single Responsibility
- Each function should do exactly one thing
- Functions should be small and focused
- If a function needs a comment to explain what it does, it should be split
## DRY (Don't Repeat Yourself)
- Extract repeated code into reusable functions
- Share common logic through proper abstraction
- Maintain single sources of truth
## Clean Structure
- Keep related code together
- Organize code in a logical hierarchy
- Use consistent file and folder naming conventions
## Encapsulation
- Hide implementation details
- Expose clear interfaces
- Move nested conditionals into well-named functions
- Move nested conditionals into well-named functions
## Code Quality Maintenance
- Refactor continuously
- Fix technical debt early
- Leave code cleaner than you found it
## Testing
- Write tests before fixing bugs
- Keep tests readable and maintainable
- Test edge cases and error conditions
## Version Control
- Write clear commit messages
- Make small, focused commits
- Use meaningful branch names
- IMPORTANT!! All imports should be done via use, bad - `new \App\Models\User() */`, god `use \App\Models\User; ... new User()`
## Summary
- After you have changed the files, check it `make check`
