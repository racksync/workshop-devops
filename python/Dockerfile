# Use an official Python runtime as the base image
FROM python:3.9-slim

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed Python packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Make port 80 available to the world outside this container
EXPOSE 80

# Define an environment variable
# Use it, for example, for setting a Flask environment
# ENV FLASK_ENV=production

# Run app.py when the container launches
CMD ["python", "app.py"]
