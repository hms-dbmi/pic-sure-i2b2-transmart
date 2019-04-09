#
SECRET_KEY = '__PSAMA_CLIENT_SECRET__'
REDIS_HOST = 'redis'
BROKER_URL = 'amqp://guest:guest@rabbitmq:5672//'
CELERY_RESULT_BACKEND = 'redis://redis:6379'
ETL_VERIFY_SSL_CERT = False
