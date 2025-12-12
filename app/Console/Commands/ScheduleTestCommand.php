<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class ScheduleTestCommand extends Command
{
    protected $signature = 'schedule:test';

    protected $description = 'Command description';

    public function handle(): void
    {
        logger()->info('From ScheduleTestCommand', ['message' => 'Test!']);
    }
}
