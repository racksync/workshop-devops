from django.urls import reverse_lazy
from django.views.generic import CreateView
from django.shortcuts import redirect
from .forms import RegistrationForm
from .models import Participant
from django.http import HttpResponse


class RegistrationView(CreateView):
    model = Participant
    form_class = RegistrationForm
    template_name = "registration/register.html"
    success_url = reverse_lazy("registration_success")


def home(request):
    """View for the root URL that redirects to the registration page or displays a home page"""
    # For a simple solution, you can just return a basic HttpResponse
    return HttpResponse(
        "<h1>Test & Quality Check</h1><p>Go to <a href='/register/'>register</a> to get started.</p>"
    )

    # Alternatively, render a template when you create one:
    # return render(request, 'registration/home.html')


def register(request):
    """Handle user registration"""
    # Placeholder for registration logic
    if request.method == "POST":
        # Process form data
        # If successful, redirect to success page
        return redirect("registration_success")

    # Display registration form
    return HttpResponse(
        "<h1>Registration Form</h1><p>This is a placeholder for the registration form.</p>"
    )

    # Alternatively, render a template when you create one:
    # return render(request, 'registration/register.html')


def registration_success(request):
    """Display registration success page"""
    return HttpResponse(
        "<h1>Registration Successful!</h1><p>Thank you for registering.</p>"
    )

    # Alternatively, render a template when you create one:
    # return render(request, 'registration/success.html')
