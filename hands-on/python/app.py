from flask import Flask, render_template, redirect, url_for, flash, request, session
from flask_wtf import FlaskForm
from wtforms import StringField, IntegerField, SelectField, RadioField, BooleanField, TextAreaField, SubmitField
from wtforms.validators import DataRequired, Email, Length, NumberRange, ValidationError
from datetime import datetime

app = Flask(__name__)
app.config['SECRET_KEY'] = 'devops-workshop-secret-key'  # Required for CSRF protection

# Class for storing form submissions
class FormSubmissions:
    def __init__(self):
        self.submissions = []

    def add_submission(self, data):
        data['timestamp'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.submissions.append(data)
        if len(self.submissions) > 5:  # Keep only the last 5 submissions
            self.submissions.pop(0)

submissions = FormSubmissions()

# Custom validator
def check_username(form, field):
    forbidden_usernames = ['admin', 'root', 'system']
    if field.data.lower() in forbidden_usernames:
        raise ValidationError(f'Username "{field.data}" is reserved.')

# Create form class
class UserForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired(), Length(min=3, max=20), check_username])
    email = StringField('Email', validators=[DataRequired(), Email()])
    age = IntegerField('Age', validators=[DataRequired(), NumberRange(min=18, message='You must be at least 18 years old.')])
    occupation = SelectField('Occupation', choices=[
        ('', 'Select Occupation'),
        ('student', 'Student'),
        ('developer', 'Developer'),
        ('designer', 'Designer'),
        ('manager', 'Manager'),
        ('other', 'Other')
    ], validators=[DataRequired()])
    experience = RadioField('Experience Level', choices=[
        ('beginner', 'Beginner'),
        ('intermediate', 'Intermediate'),
        ('advanced', 'Advanced')
    ], default='beginner')
    skills = SelectField('Primary Skill', choices=[
        ('python', 'Python'),
        ('javascript', 'JavaScript'),
        ('java', 'Java'),
        ('csharp', 'C#'),
        ('other', 'Other')
    ])
    subscribe = BooleanField('Subscribe to Newsletter')
    comments = TextAreaField('Comments', validators=[Length(max=200)])
    submit = SubmitField('Submit')

@app.route('/', methods=['GET', 'POST'])
def index():
    form = UserForm()
    if form.validate_on_submit():
        # Process the form data
        user_data = {
            'username': form.username.data,
            'email': form.email.data,
            'age': form.age.data,
            'occupation': form.occupation.data,
            'experience': form.experience.data,
            'skills': form.skills.data,
            'subscribe': form.subscribe.data,
            'comments': form.comments.data
        }
        
        # Add to submissions history
        submissions.add_submission(user_data)
        
        # Flash a success message
        flash('Form submitted successfully!', 'success')
        
        # Redirect to the same page to avoid form resubmission
        return redirect(url_for('index'))
    
    return render_template('form.html', form=form, submissions=submissions.submissions)

@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

@app.errorhandler(500)
def server_error(e):
    return render_template('500.html'), 500

if __name__ == '__main__':
    # Run the app on port 80
    app.run(host='0.0.0.0', port=80, debug=True)
