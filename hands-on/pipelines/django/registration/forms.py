from django import forms
from .models import Participant


class RegistrationForm(forms.ModelForm):
    class Meta:
        model = Participant
        fields = [
            "name",
            "email",
            "company",
            "position",
            "experience_level",
            "interested_topics",
        ]
        widgets = {
            "name": forms.TextInput(attrs={"class": "form-control"}),
            "email": forms.EmailInput(attrs={"class": "form-control"}),
            "company": forms.TextInput(
                attrs={"class": "form-control", "value": "RACKSYNC CO., LTD."}
            ),
            "position": forms.TextInput(attrs={"class": "form-control"}),
            "experience_level": forms.Select(attrs={"class": "form-select"}),
            "interested_topics": forms.Textarea(
                attrs={"class": "form-control", "rows": 4}
            ),
        }
