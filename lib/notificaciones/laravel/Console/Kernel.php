<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    /**
     * Define the application's command schedule.
     */
    protected function schedule(Schedule $schedule): void
    {
        $schedule->command('afiliados:notificar')
            ->dailyAt('08:00')
            ->appendOutputTo(storage_path('logs/scheduler-output.log'));

        $schedule->command('afiliados:notificar-pagos-imputados')
            ->dailyAt('21:00')
            ->appendOutputTo(storage_path('logs/scheduler-output.log'));
    }

    /**
     * Register the commands for the application.
     */
    protected function commands(): void
    {
        $this->load(__DIR__.'/Commands');

        require base_path('routes/console.php');
    }
}
