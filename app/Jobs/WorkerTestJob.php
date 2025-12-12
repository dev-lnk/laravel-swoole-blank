<?php

namespace App\Jobs;

use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Psr\Log\LoggerInterface;

class WorkerTestJob implements ShouldQueue
{
    use Queueable;

    public function __construct(
        private string $message,
    ) {
        //
    }

    public function handle(): void
    {
        logger()->info('From WorkerTestJob', ['message' => $this->message]);
    }
}
