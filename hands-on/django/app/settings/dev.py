from .base import *  # noqa F403

# Development-specific settings
DEBUG = True

# SECURITY: make sure to change this in production
ALLOWED_HOSTS = ["localhost", "127.0.0.1", "dev.example.com"]

# Additional development apps
INSTALLED_APPS += [  # noqa F405
    # Add development-only apps here
]

# Development-specific middleware
# MIDDLEWARE += [  # noqa F405
#     # Add development-only middleware here
# ]

# Use console email backend for development
EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"

# Development logging settings
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
        },
    },
    "root": {
        "handlers": ["console"],
        "level": "DEBUG",
    },
}
