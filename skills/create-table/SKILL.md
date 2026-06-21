---
name: create-table
description: Guide for creating a new entity with a migration, model, enum, factory, relationships, and feature tests
---

## Task

Add a new entity to the system. The implementation must include a table migration, an Eloquent model with casts, a string-backed enum for typed fields, Eloquent relationships (`BelongsTo`, `HasOne`, `HasMany`, or `BelongsToMany`), a factory, and feature tests.

Use the templates below and replace project-specific details with placeholders such as `<constant>`, `<value>`, `<table_name>`, `<Model>`, `<Enum>`, and similar names.

## Goal

Create the `<table_name>` table with the required fields and foreign keys, add the `<Model>` model with correct `$casts` and relationships to related models, and add a factory and feature tests that verify relationships, casts, database state, and expected behavior.

Where constants, string values, table names, class names, field names, or relationship names would normally be used, write placeholders instead:

- constant name: `<constant>`
- constant value: `<value>`
- table name: `<table_name>`
- model class: `<Model>`
- enum class: `<Enum>`
- field name: `<field_name>`
- relationship name: `<relationName>`

## Files and Change Locations

- `src/database/migrations/<timestamp>_create_<table_name>_table.php` — create a migration file. Implement table creation in `up()`, table deletion in `down()`, foreign keys, indexes, and delete behavior.
- `src/app/Enums/<Enum>.php` — create a string-backed enum with cases such as `case <EnumCase> = '<value>';`. Place the file in the appropriate domain module.
- `src/app/Models/<Model>.php` — create the model. Set `protected $table = '<table_name>';`, define `$casts`, add relationship methods, add the `#[UseFactory(...)]` attribute, and use the `HasFactory` trait.
- `src/database/factories/<Model>Factory.php` — create a factory for `<Model>` with default field values, enum state methods, and helpers such as `for<RelatedModel>()`.
- `src/tests/Feature/<Model>/<Model>ModelTest.php` — add feature tests that create the related object graph, verify relationships, check pivot data when relevant, call `assertDatabaseHas()`, and verify casts.
- `src/app/Models/<RelatedModel>.php` — when needed, add inverse relationships to related models, such as a `HasMany` relationship from a parent model to `<Model>`.

## Migration

Create a migration named `<timestamp>_create_<table_name>_table.php`. Define the table schema in `up()` with an `id`, business fields, foreign keys, indexes, and timestamps.

Use Laravel foreign-key helpers such as `cascadeOnDelete()`, `nullOnDelete()`, or other project-appropriate delete behavior. If a field has a foreign key, create an index for that field by default.

Do not add `->comment()` calls in migrations unless the task explicitly requires them. Do not shorten the default length of `string` columns unless the task explicitly requires a custom length.

```php
<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class () extends Migration {
    public function up(): void
    {
        Schema::createOne('<table_name>', static function (Blueprint $table): void {
            $table->id();
            $table->string('<field_description>');
            $table->unsignedBigInteger('<fk_to_parent>');
            $table->unsignedInteger('<percent_field>');
            $table->string('<enum_field>');
            $table->unsignedInteger('<nullable_days_field>')->nullable();
            $table->unsignedBigInteger('<fk_to_user_or_actor>');
            $table->timestamps();
            
            $table->foreign('<fk_to_parent>')
                ->references('id')
                ->on('<related_parent_table>')
                ->cascadeOnDelete();

            $table->foreign('<fk_to_user_or_actor>')
                ->references('id')
                ->on('<related_users_table>')
                ->restrictOnDelete();
                
            $table->index('<fk_to_parent>');
            $table->index('<fk_to_user_or_actor>');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('<table_name>');
    }
};
```

Foreign-key example:

```php
$table->unsignedBigInteger('application_id');
$table->index('application_id');
$table->foreign('application_id')
    ->references('id')
    ->on('applications')
    ->cascadeOnDelete();
```

String-column example:

```php
$table->string('column');
```

Do not write this unless a custom length was explicitly requested:

```php
$table->string('column', 25);
```

## Enum

Add a string-backed enum. Use PascalCase for enum case names. Use placeholder string values such as `'<value_a>'`.

```php
<?php

declare(strict_types=1);

namespace App\Modules\Enums;

enum <Enum>: string
{
    case <EnumCaseA> = '<value_a>';
    case <EnumCaseB> = '<value_b>';
    case <EnumCaseC> = '<value_c>';
}
```

## Model and Relationships

Create the `<Model>` model. Set the table name, add traits and casts, and define relationships. Cast the enum field to `<Enum>::class`. Cast date or datetime fields to `datetime` when needed.

Define `BelongsTo` relationships to the parent entity and, when needed, to a user, employee, or actor model. Add `HasOne`, `HasMany`, or `BelongsToMany` relationships in related models when the domain requires inverse or peer relationships.

```php
<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\AbstractModel;
use App\Models\<RelatedParentModel>;
use App\Models\Users\<UserModel>;
use App\Modules\Enums\<Enum>;
use Illuminate\Database\Eloquent\Attributes\UseFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
// use Illuminate\Database\Eloquent\Relations\BelongsToMany;
// use Illuminate\Database\Eloquent\Relations\HasMany;
// use Illuminate\Database\Eloquent\Relations\HasOne;

#[UseFactory(\Database\Factories\<Model>Factory::class)]
class <Model> extends AbstractModel
{
    use HasFactory;

    protected $table = '<table_name>';

    protected $casts = [
        '<enum_field>' => <Enum>::class,
        // '<some_date_field>' => 'datetime',
    ];

    /** @return BelongsTo<<RelatedParentModel>, $this> */
    public function <parentRelation>(): BelongsTo
    {
        return $this->belongsTo(<RelatedParentModel>::class, '<fk_to_parent>');
    }

    /** @return BelongsTo<<UserModel>, $this> */
    public function <actorRelation>(): BelongsTo
    {
        return $this->belongsTo(<UserModel>::class, '<fk_to_user_or_actor>');
    }

    // /** @return HasOne<<RelatedModel>> */
    // public function <hasOneRelation>(): HasOne
    // {
    //     return $this->hasOne(<RelatedModel>::class, '<fk_to_model>');
    // }

    // /** @return HasMany<<RelatedModel>> */
    // public function <hasManyRelation>(): HasMany
    // {
    //     return $this->hasMany(<RelatedModel>::class, '<fk_to_model>');
    // }

    // /** @return BelongsToMany<<PeerModel>> */
    // public function <manyToManyRelation>(): BelongsToMany
    // {
    //     return $this->belongsToMany(<PeerModel>::class, '<pivot_table>')
    //         ->withPivot(['<pivot_status>', '<pivot_meta>'])
    //         ->withTimestamps();
    // }
}
```

## Factory

Create `<Model>Factory` with default field values, state methods for different enum cases, and a `for<RelatedModel>()` helper that can accept either an existing model instance or a factory instance.

When a helper or service constant would normally be used, replace it with placeholders such as `<constant> = <value>` so the skill remains independent from a specific environment.

Before creating relationship helper methods, check `src/app/Services/Development/Factories`. If a suitable trait already exists, include and use it.

```php
<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\<Model>;
use App\Models\<RelatedParentModel>;
use App\Modules\Enums\<Enum>;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<<Model>>
 */
class <Model>Factory extends Factory
{
    protected $model = <Model>::class;

    public function definition(): array
    {
        return [
            '<field_description>' => $this->faker->sentence,
            '<percent_field>' => 10,
            '<enum_field>' => <Enum>::<EnumCaseA>,
            '<fk_to_user_or_actor>' => <constant>, // Example placeholder: <EmployeeRobotId> = <value>
            '<nullable_days_field>' => null,
        ];
    }

    public function as<EnumCaseA>(): self
    {
        return $this->state([
            '<enum_field>' => <Enum>::<EnumCaseA>,
            '<percent_field>' => 30,
        ]);
    }

    public function as<EnumCaseB>(): self
    {
        return $this->state([
            '<enum_field>' => <Enum>::<EnumCaseB>,
            '<percent_field>' => 100,
        ]);
    }

    public function as<EnumCaseC>(): self
    {
        return $this->state([
            '<enum_field>' => <Enum>::<EnumCaseC>,
            '<percent_field>' => 100,
            '<nullable_days_field>' => 7,
        ]);
    }

    public function for<RelatedParentModel>(<RelatedParentModel>|<RelatedParentModel>Factory|null $parent = null): self
    {
        if ($parent === null) {
            $parent = <RelatedParentModel>Factory::new();
        }

        return $this->for($parent, '<parentRelation>');
    }
}
```

## Feature Tests

In the feature test, create the required related object graph: parent entity, intermediate entities when needed, and then the `<Model>` instance through its factory and enum state method.

Verify relationships, enum casts, date casts, database records, and pivot data when the model has a `BelongsToMany` relationship. When checking values stored in the database for enum-backed fields, assert the enum `->value` unless the project has a custom assertion pattern.

```php
<?php

declare(strict_types=1);

namespace Tests\Feature\Modules\<Model>;

use App\Models\<Model>;
use App\Models\<RelatedParentModel>;
use App\Modules\Enums\<Enum>;
use Tests\Feature\BaseFeatureTestCase;

class <Model>ModelTest extends BaseFeatureTestCase
{
    public function testRelationsAndCasts(): void
    {
        $parent = <RelatedParentModel>::factory()->createOne();

        $entity = <Model>::factory()
            ->for<RelatedParentModel>($parent)
            ->as<EnumCaseC>()
            ->createOne();

        $entity->refresh();

        $this->assertTrue($entity-><parentRelation>->is($parent));
        $this->assertInstanceOf(<Enum>::class, $entity->getAttribute('<enum_field>'));

        $this->assertDatabaseHas('<table_name>', [
            'id' => $entity->id,
            '<fk_to_parent>' => $parent->id,
            '<enum_field>' => <Enum>::<EnumCaseC>->value,
        ]);

        // If the model has a BelongsToMany relationship with pivot data:
        // $peer = <PeerModel>::factory()->createOne();
        // $entity-><manyToManyRelation>()->attach($peer->id, [
        //     '<pivot_status>' => <PivotStatusEnum>::<SomeValue>->value,
        // ]);
        //
        // $this->assertDatabaseHas('<pivot_table>', [
        //     '<peer_fk>' => $peer->id,
        //     '<entity_fk>' => $entity->id,
        //     '<pivot_status>' => <PivotStatusEnum>::<SomeValue>->value,
        // ]);
    }
}
```

## Placeholder and Style Rules

- Replace all concrete constant names with `<constant>` and their concrete string or numeric values with `<value>`.
- Use placeholders for table names, class names, field names, and relationship names: `<table_name>`, `<Model>`, `<Enum>`, `<field_name>`, `<relationName>`, and similar names.
- Keep placeholders wrapped in backticks in Markdown prose so they render correctly.
- Use `declare(strict_types=1);` in PHP files.
- Use typed method signatures.
- Add PHPDoc annotations for model properties, relationship return types, and builder methods when the project requires them.
- Follow PSR-12 formatting.

## Laravel Notes

- Use the `#[UseFactory(...)]` attribute and the `HasFactory` trait to connect the model with its factory.
- Define enum casts in `$casts` by mapping the string column to the enum class, for example `'<enum_field>' => <Enum>::class`.
- Do not add migration comments with `->comment()` unless the task explicitly asks for them.
- Use Laravel delete-behavior helpers for foreign keys, such as `cascadeOnDelete()`, `nullOnDelete()`, or `restrictOnDelete()`.
- Add an index for every foreign-key field by default.
- Do not shorten the default `string` column length unless the task explicitly asks for a custom length.

## Completion Checklist

After making the implementation changes:

1. Run the relevant feature tests.
2. Run `make check`.
3. Fix all formatting, static-analysis, and test failures.
