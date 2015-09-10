threads_min = Integer(ENV['MIN_THREADS'] || 5)
threads_max = Integer(ENV['MAX_THREADS'] || 32)
threads threads_min, threads_max

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 5000
environment ENV['RACK_ENV'] || 'development'