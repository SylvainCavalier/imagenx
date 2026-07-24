# Good Job configuration
Rails.application.configure do
  config.active_job.queue_adapter = :good_job

  # Configure Good Job to use PostgreSQL for job storage
  # Jobs will be stored in the same database as your application
  config.good_job.enable_cron = true
  config.good_job.cron = {
    # Example cron job (commented out)
    # cleanup_job: {
    #   cron: "0 0 * * *", # Daily at midnight
    #   class: "CleanupJob"
    # }
  }

  # Preserve job records for debugging
  config.good_job.preserve_job_records = true
  
  # Clean up old jobs after 7 days
  config.good_job.cleanup_preserved_jobs_before_seconds_ago = 7.days.to_i
  
  # Set maximum number of threads
  config.good_job.max_threads = ENV.fetch("GOOD_JOB_MAX_THREADS", 5).to_i

  # Enable dashboard in development
  config.good_job.enable_listen_notify = Rails.env.development?

  # Single Basic dyno on Heroku: no separate worker process, so jobs run as
  # in-process threads inside the web dyno instead of GoodJob's default :external mode.
  config.good_job.execution_mode = :async if Rails.env.production?
end
