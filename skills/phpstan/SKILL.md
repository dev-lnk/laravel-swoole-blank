---
name: php
description: Best practices in PHP for use in this project
---

# When to use
Always when you edit or create a file in the `src` directory

# Laravel 13 + Larastan + PHPStan Level Max Typing Skill for PHP 8.5

## Purpose

Focus on:

* PHPStan level Max correctness;
* Larastan-aware Laravel typing;
* Eloquent model and relation generics;
* Collection and Eloquent Collection generics;
* Builder generics;
* Form Request validation shapes;
* Resources, DTOs, Actions, Jobs, Events, Listeners, Policies, Rules, Casts, Notifications, Mailables, Commands, and Services;
* avoiding unsafe Laravel magic when explicit types are better;
* preserving runtime behavior.

## Primary Goal

Given Laravel PHP code, produce a typed version that is acceptable for Larastan / PHPStan level Max without weakening analysis, hiding real errors, or changing runtime behavior.

The result must be:

* behavior-preserving;
* idiomatic Laravel 13;
* PHP 8.5-compatible;
* explicit about nullable values;
* precise about Eloquent models, relations, builders, collections, request payloads, resources, and arrays;
* free from unnecessary `mixed`;
* free from unsafe access to nullable values;
* free from misleading PHPDoc;
* compatible with Larastan’s understanding of Laravel magic.

## PHPStan Level Max Requirements

Respect all cumulative PHPStan checks up to level Max:

1. Undefined classes, functions, methods, properties, constants, and variables must be fixed.
2. Possibly undefined variables must be handled.
3. PHPDoc must be valid and must not contradict native types.
4. Return types and property assignment types must be correct.
5. Argument types must match function and method declarations.
6. Missing type hints must be added.
7. Union types must be narrowed before accessing members that exist only on some union branches.
8. Nullable values must be checked before calling methods or accessing properties.

At level Max, this is invalid:

```php
$user = User::query()->find($id);

return $user->email;
```

Correct alternatives:

```php
$user = User::query()->find($id);

if ($user === null) {
    throw new ModelNotFoundException();
}

return $user->email;
```

or:

```php
return User::query()->find($id)?->email;
```

Only use the nullsafe operator when `null` is a valid business result.

## Laravel and Larastan Principles

Prefer code that Larastan can understand naturally:

* use native return types on relations;
* add generic PHPDoc on Eloquent relations;
* avoid dynamic properties unless they are real Eloquent attributes or relations;
* avoid `Model::make()` when `new Model()` is clearer;
* prefer query-level operations over loading full collections unnecessarily;
* use typed DTOs or array shapes for validated input;
* use explicit builders, collections, and resources;
* use framework-specific PHPStan extensions instead of suppressing framework magic.

Do not silence Larastan errors by making everything `mixed`, `array`, `object`, or `Model`.

## Native Types First

Use native PHP types wherever PHP can express the type.

```php
public function show(int $id): JsonResponse
```

```php
public function handle(ProcessOrder $job): void
```

```php
public function authorize(): bool
```

Use PHPDoc only when native PHP cannot express the full type, such as generics, array shapes, literal strings, class strings, or callable signatures.

## No Bare Arrays

Do not leave `array` untyped in PHPDoc.

Bad:

```php
/** @param array $data */
public function store(array $data): User
```

Good:

```php
/**
 * @param array{
 *     name: non-empty-string,
 *     email: non-empty-string,
 *     password: non-empty-string,
 *     roles?: list<non-empty-string>
 * } $data
 */
public function store(array $data): User
```

Use:

* `array<string, mixed>` only at external boundaries;
* `array<string, string>` for flat string maps;
* `list<T>` for zero-indexed sequential arrays;
* `non-empty-list<T>` when at least one item is required;
* `array{...}` for structured validated payloads.

## Eloquent Models

Every model should be understandable to Larastan.

Prefer explicit model properties through PHPDoc only when needed:

```php
/**
 * @property int $id
 * @property non-empty-string $email
 * @property string|null $name
 * @property CarbonImmutable|null $email_verified_at
 *
 * @property-read Collection<int, Post> $posts
 */
class User extends Authenticatable
{
}
```

Do not add inaccurate `@property` tags. They must match casts, accessors, mutators, database columns, and relations.

Prefer typed casts:

```php
/**
 * @return array{
 *     email_verified_at: 'immutable_datetime',
 *     is_admin: 'boolean',
 *     settings: 'array'
 * }
 */
protected function casts(): array
{
    return [
        'email_verified_at' => 'immutable_datetime',
        'is_admin' => 'boolean',
        'settings' => 'array',
    ];
}
```

When an attribute is complex, prefer a custom cast, value object, DTO, or precise accessor return type.

## Eloquent Relation Return Types

Every relation method must have:

1. a native relation return type;
2. a Larastan-compatible generic PHPDoc return type.

Example:

```php
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * @return HasMany<Post, $this>
 */
public function posts(): HasMany
{
    return $this->hasMany(Post::class);
}
```

Common relation annotations:

```php
use Illuminate\Database\Eloquent\Relations\HasOne;

/** @return HasOne<Profile, $this> */
public function profile(): HasOne
{
    return $this->hasOne(Profile::class);
}
```

```php
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** @return BelongsTo<User, $this> */
public function user(): BelongsTo
{
    return $this->belongsTo(User::class);
}
```

```php
use Illuminate\Database\Eloquent\Relations\HasMany;

/** @return HasMany<Comment, $this> */
public function comments(): HasMany
{
    return $this->hasMany(Comment::class);
}
```

```php
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

/** @return BelongsToMany<Role, $this> */
public function roles(): BelongsToMany
{
    return $this->belongsToMany(Role::class);
}
```

```php
use Illuminate\Database\Eloquent\Relations\MorphTo;
use Illuminate\Database\Eloquent\Model;

/** @return MorphTo<Model, $this> */
public function commentable(): MorphTo
{
    return $this->morphTo();
}
```

```php
use Illuminate\Database\Eloquent\Relations\MorphMany;

/** @return MorphMany<Comment, $this> */
public function comments(): MorphMany
{
    return $this->morphMany(Comment::class, 'commentable');
}
```

When using advanced relations such as `HasManyThrough`, `HasOneThrough`, `MorphToMany`, or `MorphedByMany`, specify all required generic parameters according to the installed Laravel / Larastan stubs.

Do not write:

```php
/** @return HasMany */
public function posts(): HasMany
```

because the related model type is lost.

## Accessing Relations

Distinguish relation methods from loaded relation properties.

Relation method:

```php
$user->posts()->where('published', true)->exists();
```

Loaded relation property:

```php
$user->posts->map(fn (Post $post): string => $post->title);
```

Before using a possibly unloaded relation as a property, make sure the code is logically safe. Prefer eager loading when the code requires the relation:

```php
$user = User::query()
    ->with('posts')
    ->findOrFail($id);
```

When nullable relations are possible, handle null explicitly:

```php
$profile = $user->profile;

if ($profile === null) {
    return null;
}

return $profile->timezone;
```

## Eloquent Builders

Use generic builder annotations when returning query builders.

```php
use Illuminate\Database\Eloquent\Builder;

/**
 * @return Builder<User>
 */
public function activeUsers(): Builder
{
    return User::query()->where('active', true);
}
```

For local scopes, use Laravel-compatible signatures:

```php
use Illuminate\Database\Eloquent\Builder;

/**
 * @param Builder<User> $query
 * @return Builder<User>
 */
public function scopeActive(Builder $query): Builder
{
    return $query->where('active', true);
}
```

For custom Eloquent builders:

```php
/**
 * @extends Builder<User>
 */
final class UserBuilder extends Builder
{
    public function active(): self
    {
        return $this->where('active', true);
    }
}
```

Then wire the model carefully:

```php
/**
 * @param \Illuminate\Database\Query\Builder $query
 * @return UserBuilder
 */
public function newEloquentBuilder($query): UserBuilder
{
    return new UserBuilder($query);
}
```

## Query Results

Handle nullable query results explicitly.

Bad:

```php
$user = User::query()->where('email', $email)->first();

return $user->id;
```

Good:

```php
$user = User::query()->where('email', $email)->first();

if ($user === null) {
    throw new UserNotFoundException($email);
}

return $user->id;
```

Prefer Laravel methods that encode the expected behavior:

```php
$user = User::query()->where('email', $email)->firstOrFail();
```

Use `findOrFail`, `firstOrFail`, `sole`, or explicit null checks when the result must exist.

## Collections

Always specify collection key and value types.

For support collections:

```php
use Illuminate\Support\Collection;

/**
 * @return Collection<int, string>
 */
public function names(): Collection
{
    return collect(['Taylor', 'Nuno']);
}
```

For Eloquent collections:

```php
use Illuminate\Database\Eloquent\Collection;

/**
 * @return Collection<int, User>
 */
public function users(): Collection
{
    return User::query()->where('active', true)->get();
}
```

When mapping collections, type callback parameters and return values:

```php
/**
 * @return Collection<int, UserDto>
 */
public function userDtos(): Collection
{
    return User::query()
        ->get()
        ->map(fn (User $user): UserDto => UserDto::fromModel($user));
}
```

If `toArray()` is used, specify the exact output shape:

```php
/**
 * @return list<array{
 *     id: int,
 *     email: string
 * }>
 */
public function usersArray(): array
{
    return User::query()
        ->get()
        ->map(fn (User $user): array => [
            'id' => $user->id,
            'email' => $user->email,
        ])
        ->values()
        ->all();
}
```

Use `values()` before returning `list<T>` after filtering, because `filter()` preserves original keys.

## Avoid Unnecessary Collection Calls

Prefer database-level queries over loading collections when possible.

Bad:

```php
$count = User::all()->count();
```

Good:

```php
$count = User::query()->count();
```

Bad:

```php
$exists = $user->roles->pluck('name')->contains('admin');
```

Good:

```php
$exists = $user->roles()->where('name', 'admin')->exists();
```

Do not load entire collections only to call `count`, `contains`, `first`, `pluck`, or `exists` when a query can answer the question.

## Form Requests

Type Form Request methods precisely.

```php
use Illuminate\Foundation\Http\FormRequest;

final class StoreUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array{
     *     name: list<string>,
     *     email: list<string>,
     *     password: list<string>,
     *     roles: list<string>
     * }
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email'],
            'password' => ['required', 'string', 'min:12'],
            'roles' => ['array'],
        ];
    }

    /**
     * @return array{
     *     name: non-empty-string,
     *     email: non-empty-string,
     *     password: non-empty-string,
     *     roles?: list<non-empty-string>
     * }
     */
    public function validatedData(): array
    {
        /** @var array{
         *     name: non-empty-string,
         *     email: non-empty-string,
         *     password: non-empty-string,
         *     roles?: list<non-empty-string>
         * } $data
         */
        $data = $this->validated();

        return $data;
    }
}
```

Do not pass raw `$request->all()` into services. Use validated data, DTOs, or value objects.

Preferred controller usage:

```php
public function store(StoreUserRequest $request, CreateUserAction $createUser): JsonResponse
{
    $user = $createUser->execute(UserInput::fromArray($request->validatedData()));

    return response()->json(UserResource::make($user), 201);
}
```

## Request Input

Raw request input is dynamic. Treat it as untrusted.

Bad:

```php
$email = $request->input('email');
$user = User::query()->where('email', $email)->first();
```

Good:

```php
$email = $request->string('email')->toString();
```

Better:

```php
/** @var non-empty-string $email */
$email = $request->validated('email');
```

Best for reusable application logic:

```php
final readonly class UserInput
{
    public function __construct(
        public string $email,
        public string $name,
    ) {
        if ($this->email === '') {
            throw new InvalidArgumentException('Email must not be empty.');
        }

        if ($this->name === '') {
            throw new InvalidArgumentException('Name must not be empty.');
        }
    }

    /**
     * @param array{
     *     email: non-empty-string,
     *     name: non-empty-string
     * } $data
     */
    public static function fromArray(array $data): self
    {
        return new self(
            email: $data['email'],
            name: $data['name'],
        );
    }
}
```

## Controllers

Controllers should be thin and typed.

```php
final class UserController
{
    public function show(User $user): UserResource
    {
        return UserResource::make($user);
    }

    public function store(StoreUserRequest $request, CreateUserAction $action): JsonResponse
    {
        $user = $action->execute(UserInput::fromArray($request->validatedData()));

        return response()->json(UserResource::make($user), 201);
    }
}
```

Avoid business logic in controllers. Move logic into typed services, actions, commands, or domain classes.

## API Resources

Type Laravel resources explicitly.

```php
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin User
 */
final class UserResource extends JsonResource
{
    /**
     * @return array{
     *     id: int,
     *     email: string,
     *     name: string|null
     * }
     */
    public function toArray(Request $request): array
    {
        /** @var User $user */
        $user = $this->resource;

        return [
            'id' => $user->id,
            'email' => $user->email,
            'name' => $user->name,
        ];
    }
}
```

For resource collections:

```php
use Illuminate\Http\Resources\Json\ResourceCollection;

/**
 * @extends ResourceCollection<int, User>
 */
final class UserCollection extends ResourceCollection
{
    /**
     * @return array{
     *     data: list<array{
     *         id: int,
     *         email: string
     *     }>
     * }
     */
    public function toArray(Request $request): array
    {
        return [
            'data' => $this->collection
                ->map(fn (User $user): array => [
                    'id' => $user->id,
                    'email' => $user->email,
                ])
                ->values()
                ->all(),
        ];
    }
}
```

When using Laravel 13 JSON:API resources, type resource objects, relationships, links, meta, and sparse fieldsets explicitly with array shapes or dedicated DTOs.

## Services and Actions

Use strongly typed action classes.

```php
final readonly class CreateUserAction
{
    public function __construct(
        private UserRepository $users,
        private Hasher $hasher,
    ) {
    }

    public function execute(UserInput $input): User
    {
        return $this->users->create($input);
    }
}
```

Avoid service methods like:

```php
public function execute(array $data)
```

unless the array has a precise shape.

## Repositories

Use generics for reusable repositories.

```php
/**
 * @template TModel of Model
 */
interface Repository
{
    /**
     * @return TModel|null
     */
    public function find(int $id): ?Model;
}
```

Concrete repository:

```php
/**
 * @implements Repository<User>
 */
final readonly class UserRepository implements Repository
{
    public function find(int $id): ?User
    {
        return User::query()->find($id);
    }
}
```

For Laravel applications, do not add repositories just to satisfy PHPStan. Use them when they clarify domain boundaries.

## Factories

Specify factory generics on models using `HasFactory`.

```php
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Database\Factories\UserFactory;

/**
 * @use HasFactory<UserFactory>
 */
class User extends Authenticatable
{
    use HasFactory;
}
```

Factory classes should specify the model they create:

```php
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<User>
 */
final class UserFactory extends Factory
{
    protected $model = User::class;

    /**
     * @return array{
     *     name: string,
     *     email: string,
     *     password: string
     * }
     */
    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'email' => fake()->safeEmail(),
            'password' => bcrypt('password'),
        ];
    }
}
```

## Seeders

Type seeders normally and avoid dynamic untyped payloads.

```php
final class UserSeeder extends Seeder
{
    public function run(): void
    {
        User::factory()->count(10)->create();
    }
}
```

If using arrays:

```php
/**
 * @var list<array{
 *     name: non-empty-string,
 *     email: non-empty-string
 * }> $users
 */
$users = [
    ['name' => 'Admin', 'email' => 'admin@example.com'],
];
```

## Jobs

Jobs should have typed constructor properties and typed `handle` methods.

```php
final class SendWelcomeEmail implements ShouldQueue
{
    use Dispatchable;
    use Queueable;

    public function __construct(
        public readonly int $userId,
    ) {
    }

    public function handle(UserRepository $users): void
    {
        $user = $users->find($this->userId);

        if ($user === null) {
            return;
        }

        Mail::to($user->email)->send(new WelcomeMail($user));
    }
}
```

Do not serialize entire Eloquent models into jobs unless that is intentional and safe. Prefer IDs when the model may change or be deleted before execution.

For Laravel 13 queue routing or queue attributes, keep class names typed with `class-string<ShouldQueue>` where applicable.

## Events and Listeners

Events should expose typed readonly data.

```php
final readonly class UserRegistered
{
    public function __construct(
        public User $user,
    ) {
    }
}
```

Listeners should type their event parameter:

```php
final class SendUserRegisteredNotification
{
    public function handle(UserRegistered $event): void
    {
        $event->user->notify(new WelcomeNotification());
    }
}
```

## Notifications and Mailables

Type constructor dependencies and `toMail`, `toArray`, and channel methods.

```php
/**
 * @return array<string>
 */
public function via(object $notifiable): array
{
    return ['mail'];
}
```

```php
/**
 * @return array{
 *     invoice_id: int,
 *     amount: int
 * }
 */
public function toArray(object $notifiable): array
{
    return [
        'invoice_id' => $this->invoiceId,
        'amount' => $this->amount,
    ];
}
```

Do not use untyped `$notifiable` behavior without narrowing if accessing model-specific properties.

```php
public function toMail(object $notifiable): MailMessage
{
    if (!$notifiable instanceof User) {
        throw new InvalidArgumentException('Expected User notifiable.');
    }

    return (new MailMessage())->to($notifiable->email);
}
```

## Policies

Type model and user parameters.

```php
final class PostPolicy
{
    public function update(User $user, Post $post): bool
    {
        return $post->user_id === $user->id;
    }
}
```

When a policy method may receive a nullable user, type it explicitly:

```php
public function view(?User $user, Post $post): bool
{
    return $post->is_public || $user?->id === $post->user_id;
}
```

## Validation Rules

Custom validation rules should be typed.

```php
use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

final class Uppercase implements ValidationRule
{
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (!is_string($value)) {
            $fail('The :attribute must be a string.');

            return;
        }

        if (strtoupper($value) !== $value) {
            $fail('The :attribute must be uppercase.');
        }
    }
}
```

Use `mixed` only because Laravel validation passes dynamic values. Narrow before using.

## Casts

Custom casts must type their dynamic input carefully.

```php
use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
use Illuminate\Database\Eloquent\Model;

/**
 * @implements CastsAttributes<Money, array{amount: int, currency: string}>
 */
final class MoneyCast implements CastsAttributes
{
    public function get(Model $model, string $key, mixed $value, array $attributes): Money
    {
        if (!is_string($value)) {
            throw new UnexpectedValueException('Expected JSON string.');
        }

        /** @var array{amount: int, currency: string} $data */
        $data = json_decode($value, true, flags: JSON_THROW_ON_ERROR);

        return new Money($data['amount'], $data['currency']);
    }

    public function set(Model $model, string $key, mixed $value, array $attributes): array
    {
        if (!$value instanceof Money) {
            throw new InvalidArgumentException('Expected Money.');
        }

        return [
            $key => json_encode([
                'amount' => $value->amount,
                'currency' => $value->currency,
            ], JSON_THROW_ON_ERROR),
        ];
    }
}
```

## Accessors and Mutators

Type accessors and mutators explicitly.

```php
use Illuminate\Database\Eloquent\Casts\Attribute;

/**
 * @return Attribute<string, string>
 */
protected function fullName(): Attribute
{
    return Attribute::make(
        get: fn (mixed $value, array $attributes): string => trim(
            (string) $attributes['first_name'] . ' ' . (string) $attributes['last_name']
        ),
    );
}
```

Avoid assuming `$attributes` keys exist unless the model schema guarantees them. Use precise shapes when possible:

```php
/**
 * @param array{first_name: string, last_name: string} $attributes
 */
private function buildFullName(array $attributes): string
{
    return trim($attributes['first_name'] . ' ' . $attributes['last_name']);
}
```

## Enums

Prefer PHP backed enums for closed sets.

```php
enum OrderStatus: string
{
    case Draft = 'draft';
    case Paid = 'paid';
    case Cancelled = 'cancelled';
}
```

Use enum casts:

```php
/**
 * @return array{
 *     status: class-string<OrderStatus>
 * }
 */
protected function casts(): array
{
    return [
        'status' => OrderStatus::class,
    ];
}
```

When accepting enum values from request data, convert at the boundary:

```php
$status = OrderStatus::from($request->validatedData()['status']);
```

## Routes

Route model binding should be reflected in controller signatures.

```php
Route::get('/users/{user}', [UserController::class, 'show']);
```

```php
public function show(User $user): UserResource
{
    return UserResource::make($user);
}
```

For raw route parameters, cast and validate explicitly:

```php
$id = $request->route('id');

if (!is_numeric($id)) {
    abort(404);
}

$user = User::query()->findOrFail((int) $id);
```

## Config

Config values are mixed by default. Narrow or wrap them.

Bad:

```php
$ttl = config('cache.ttl');
return now()->addSeconds($ttl);
```

Good:

```php
$ttl = config('cache.ttl');

if (!is_int($ttl)) {
    throw new RuntimeException('cache.ttl must be an integer.');
}

return now()->addSeconds($ttl);
```

Better:

```php
final readonly class CacheConfig
{
    public function ttl(): int
    {
        $ttl = config('cache.ttl');

        if (!is_int($ttl)) {
            throw new RuntimeException('cache.ttl must be an integer.');
        }

        return $ttl;
    }
}
```

For config files, use precise array shapes where useful:

```php
/**
 * @return array{
 *     default: string,
 *     stores: array<string, array<string, mixed>>
 * }
 */
return [
    'default' => env('CACHE_STORE', 'database'),
    'stores' => [
        // ...
    ],
];
```

## Environment Values

`env()` is for config files. Do not use `env()` throughout application code.

When reading config, narrow the type:

```php
$value = config('services.stripe.key');

if (!is_string($value) || $value === '') {
    throw new RuntimeException('Stripe key is not configured.');
}
```

Use `non-empty-string` PHPDoc after validation when helpful:

```php
/** @var non-empty-string $apiKey */
$apiKey = $value;
```

## Facades

Facades are understood by Larastan better than plain PHPStan, but do not overuse them in domain code.

Prefer dependency injection for services:

```php
public function __construct(
    private readonly Dispatcher $events,
) {
}
```

Facade usage is acceptable in framework edges, tests, controllers, commands, jobs, and bootstrapping when idiomatic.

When a facade returns dynamic data, narrow the result.

## Container Resolution

Container results are often `mixed` or `object`. Prefer typed dependencies via constructor injection.

Bad:

```php
$service = app('billing');
$service->charge($invoice);
```

Good:

```php
public function __construct(
    private readonly BillingService $billing,
) {
}
```

If container resolution is necessary:

```php
$service = app(BillingService::class);
$service->charge($invoice);
```

Use `class-string<T>` for generic factories:

```php
/**
 * @template T of object
 * @param class-string<T> $className
 * @return T
 */
public function resolve(string $className): object
{
    return app($className);
}
```

## Commands

Artisan command arguments and options are dynamic. Narrow them.

```php
public function handle(): int
{
    $userId = $this->argument('user');

    if (!is_numeric($userId)) {
        $this->error('User ID must be numeric.');

        return self::FAILURE;
    }

    $user = User::query()->findOrFail((int) $userId);

    // ...

    return self::SUCCESS;
}
```

For options:

```php
$force = $this->option('force');

if (!is_bool($force)) {
    $force = false;
}
```

## Tests

Test code should also be typed.

```php
public function test_user_can_register(): void
{
    $response = $this->postJson('/register', [
        'name' => 'Taylor',
        'email' => 'taylor@example.com',
        'password' => 'password-password',
    ]);

    $response->assertCreated();
}
```

When using factories:

```php
$user = User::factory()->create();

self::assertInstanceOf(User::class, $user);
```

When a test helper returns a model, type it:

```php
private function createUser(): User
{
    return User::factory()->create();
}
```

## Database Rows and Raw Queries

Raw query results are dynamic. Convert them immediately.

Bad:

```php
$row = DB::table('users')->first();

return $row->email;
```

Good:

```php
$row = DB::table('users')->where('id', $id)->first();

if ($row === null) {
    throw new RuntimeException('User not found.');
}

if (!property_exists($row, 'email') || !is_string($row->email)) {
    throw new RuntimeException('Invalid user row.');
}

return $row->email;
```

Better:

```php
final readonly class UserRow
{
    public function __construct(
        public int $id,
        public string $email,
    ) {
    }

    public static function fromObject(object $row): self
    {
        if (!property_exists($row, 'id') || !is_int($row->id)) {
            throw new UnexpectedValueException('Invalid id.');
        }

        if (!property_exists($row, 'email') || !is_string($row->email)) {
            throw new UnexpectedValueException('Invalid email.');
        }

        return new self($row->id, $row->email);
    }
}
```

Prefer Eloquent or typed query objects when possible.

## Pagination

Type paginator item values.

```php
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

/**
 * @return LengthAwarePaginator<User>
 */
public function index(): LengthAwarePaginator
{
    return User::query()->paginate(20);
}
```

For transformed paginator data, specify the output shape:

```php
/**
 * @return LengthAwarePaginator<array{id: int, email: string}>
 */
public function index(): LengthAwarePaginator
{
    return User::query()
        ->paginate(20)
        ->through(fn (User $user): array => [
            'id' => $user->id,
            'email' => $user->email,
        ]);
}
```

## Laravel 13 and PHP 8.5 Notes

For Laravel 13 on PHP 8.5:

* avoid legacy global helper conflicts such as custom `array_first()` or `array_last()`;
* prefer `Illuminate\Support\Arr::first()` and related `Arr` helpers;
* do not introduce custom helpers that conflict with PHP 8.5 polyfilled global functions;
* use attributes where Laravel 13 supports them, but keep their arguments type-safe;
* when using Laravel AI SDK or JSON:API resources, wrap dynamic provider responses into typed DTOs before passing them deeper into the application.

## Dynamic AI, JSON, and API Data

External API responses, AI SDK outputs, JSON payloads, webhook payloads, and queue payloads must be treated as `mixed` at the boundary and converted into typed structures.

```php
$response = json_decode($json, true, flags: JSON_THROW_ON_ERROR);

if (!is_array($response)) {
    throw new UnexpectedValueException('Expected JSON object.');
}

/** @var array{
 *     id: non-empty-string,
 *     status: 'pending'|'completed'|'failed'
 * } $response
 */
return WebhookPayload::fromArray($response);
```

Prefer DTOs:

```php
final readonly class WebhookPayload
{
    public function __construct(
        public string $id,
        public string $status,
    ) {
        if ($this->id === '') {
            throw new InvalidArgumentException('ID must not be empty.');
        }
    }

    /**
     * @param array{
     *     id: non-empty-string,
     *     status: 'pending'|'completed'|'failed'
     * } $data
     */
    public static function fromArray(array $data): self
    {
        return new self($data['id'], $data['status']);
    }
}
```

## Custom PHPStan / Larastan Stubs

Use stubs when Laravel magic, macros, package methods, or vendor PHPDoc are not precise enough.

Create stubs for:

* macros;
* dynamic methods;
* package-specific builders;
* package-specific collections;
* incorrect vendor PHPDoc;
* facades returning project-specific services.

Do not edit vendor code.

Do not suppress errors caused by missing package types when a stub or extension can model them correctly.

## Macros

Laravel macros are dynamic. Teach Larastan about them with stubs or typed wrapper methods.

Bad:

```php
Collection::macro('active', function () {
    return $this->filter(fn ($item) => $item->active);
});
```

Better:

```php
/**
 * @template T of HasActiveFlag
 * @param Collection<int, T> $items
 * @return Collection<int, T>
 */
function activeItems(Collection $items): Collection
{
    return $items->filter(fn (HasActiveFlag $item): bool => $item->isActive());
}
```

If macros are required, provide a stub file so Larastan knows the macro signature.

## Middleware

Type middleware signatures.

```php
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

final class EnsureUserIsAdmin
{
    /**
     * @param Closure(Request): Response $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user instanceof User || !$user->isAdmin()) {
            abort(403);
        }

        return $next($request);
    }
}
```

## Authentication

`auth()->user()` and `$request->user()` are nullable and may be a generic authenticatable user. Narrow them.

Bad:

```php
return $request->user()->email;
```

Good:

```php
$user = $request->user();

if (!$user instanceof User) {
    abort(401);
}

return $user->email;
```

In code that requires an authenticated user, create a helper with assertion annotations:

```php
/**
 * @phpstan-assert User $user
 */
function assertAppUser(mixed $user): void
{
    if (!$user instanceof User) {
        throw new AuthenticationException();
    }
}
```

## Authorization

Gate and policy calls should use real model instances or class strings.

```php
$this->authorize('update', $post);
```

For class-based checks:

```php
$this->authorize('create', Post::class);
```

When wrapping authorization, type the ability as a literal union if the set is known:

```php
/**
 * @param 'view'|'create'|'update'|'delete' $ability
 */
public function ensureAuthorized(User $user, string $ability, Post $post): void
{
    Gate::forUser($user)->authorize($ability, $post);
}
```

## Mail, Queue, Cache, and Redis

Framework stores often return dynamic values. Narrow them.

Cache:

```php
$value = Cache::get('user-count');

if (!is_int($value)) {
    $value = 0;
}
```

Redis:

```php
$value = Redis::get('key');

if (!is_string($value) && $value !== null) {
    throw new UnexpectedValueException('Unexpected Redis value.');
}
```

Queue payloads should be converted to typed commands or DTOs.

## Date and Time

Prefer `CarbonImmutable` or `DateTimeImmutable` when mutation is not intended.

For nullable timestamps:

```php
if ($user->email_verified_at === null) {
    return false;
}

return $user->email_verified_at->isPast();
```

Do not call Carbon methods on nullable timestamp attributes without narrowing.

## Files and Uploads

Uploaded files are nullable unless validation guarantees their presence.

```php
$file = $request->file('avatar');

if (!$file instanceof UploadedFile) {
    throw new InvalidArgumentException('Avatar is required.');
}

$path = $file->store('avatars');

if ($path === false) {
    throw new RuntimeException('Failed to store avatar.');
}
```

Use validation and Form Requests to reduce dynamic file handling.

## Error Handling and Exceptions

Use precise exceptions when a missing model, invalid input, or impossible state is detected.

```php
if ($user === null) {
    throw new UserNotFoundException($id);
}
```

Use `@throws` only when the project documents exceptions or when the method contract benefits from it.

```php
/**
 * @throws UserNotFoundException
 */
public function get(int $id): User
```

## Suppressions

Avoid suppressions.

Do not use:

```php
// @phpstan-ignore-line
```

or:

```php
// @phpstan-ignore-next-line
```

unless explicitly requested.

If suppression is unavoidable, use a specific error identifier and explain the reason.

```php
// @phpstan-ignore argument.type (Vendor PHPDoc is incorrect; covered by integration test.)
```

Prefer:

* better PHPDoc;
* DTOs;
* stubs;
* Larastan extensions;
* typed wrappers;
* explicit runtime validation.

## Baselines

A baseline may be used only as a temporary migration tool for legacy code.

Do not add new errors to the baseline.

When editing code, remove baseline entries that become obsolete.

New code must pass Larastan at level Max without baseline exceptions.

## Refactoring Priorities

When fixing Laravel code for Larastan level Max, use this order:

1. Add native parameter, return, and property types.
2. Add Eloquent relation generics.
3. Add Builder and Collection generics.
4. Replace raw arrays with DTOs or array shapes.
5. Replace raw request data with validated data.
6. Handle nullable Eloquent results explicitly.
7. Narrow authenticated users and dynamic framework values.
8. Type resources, factories, casts, rules, jobs, listeners, commands, and notifications.
9. Add stubs for macros or vendor magic.
10. Use targeted suppressions only as a last resort.

## Output Format

When given Laravel code, respond with:

1. A corrected PHP code block.
2. A short list of important typing changes.
3. Any Laravel / Larastan assumptions made.
4. Any remaining risks that require project context.

If the user asks for a diff, provide a unified diff.

If the user asks for only code, output only code.

## Final Checklist

Before returning code, verify:

* PHP 8.5 compatibility is preserved;
* Laravel 13 APIs are used correctly;
* Larastan extension assumptions are respected;
* all methods and functions have native parameter and return types;
* all properties are typed;
* Eloquent relations have native relation return types;
* Eloquent relations have generic PHPDoc return types;
* builders have model generics where needed;
* collections have key and value generics;
* request data is validated or narrowed;
* resources have precise output shapes;
* jobs, events, listeners, policies, rules, casts, notifications, mailables, and commands are typed;
* nullable query results are handled;
* nullable authenticated users are narrowed;
* no method or property is accessed on a nullable value without checks;
* union types are narrowed before member access;
* no unnecessary `mixed` remains;
* any necessary `mixed` value is narrowed before use;
* no bare PHPDoc `array` or `iterable` remains where a precise type is possible;
* no inaccurate PHPDoc was added;
* no new broad suppressions were introduced;
* Laravel magic is modeled with Larastan, stubs, or explicit wrappers rather than ignored.
