require 'sidekiq-scheduler'

class BaseScheduler
  Sidekiq::Job

end

