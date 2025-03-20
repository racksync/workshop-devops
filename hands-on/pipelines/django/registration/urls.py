from django.urls import path
from . import views

urlpatterns = [
    path("", views.home, name="home"),  # Add this for the root path
    path("register/", views.RegistrationView.as_view(), name="register"),
    path("register/success/", views.registration_success, name="registration_success"),
]
