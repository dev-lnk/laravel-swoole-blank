<?php

namespace Tests\Feature;

use PHPUnit\Framework\Attributes\Test;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    #[Test]
    public function homePage(): void
    {
        $response = $this->get('/');
        $response->assertStatus(200);
    }
}
