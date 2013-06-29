web:    bundle exec rackup config.ru -p $PORT
worker: bundle exec rake resque:work QUEUE=* TERM_CHILD=1
redis:  redis-server --bind 127.0.0.1