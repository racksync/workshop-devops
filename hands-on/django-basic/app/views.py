from django.shortcuts import render
from django.http import HttpResponse
import platform
import os


def index(request):
    context = {
        'title': 'DevOps Workshop - Django Example',
        'python_version': platform.python_version(),
        'django_version': os.environ.get('DJANGO_VERSION', 'Development'),
        'hostname': platform.node(),
    }
    return render(request, 'app/index.html', context)
