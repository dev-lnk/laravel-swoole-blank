<?php

namespace App\Console\Commands;

use App\Jobs\WorkerTestJob;
use Illuminate\Console\Command;

class WorkerTestCommand extends Command
{
    protected $signature = 'worker:test';

    protected $description = 'Command description';

    public function handle(): void
    {
        WorkerTestJob::dispatch('Test from command!');
    }
}
