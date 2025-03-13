from flask import Flask, render_template_string

app = Flask(__name__)

@app.route('/')
def home():
    html = '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Docker Hub Workshop</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                max-width: 800px;
                margin: 0 auto;
                padding: 20px;
            }
            h1 {
                color: #0066cc;
            }
            .container {
                border: 1px solid #ddd;
                padding: 20px;
                border-radius: 5px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Docker Hub CI/CD Workshop</h1>
            <p>This is a simple Flask application that demonstrates CI/CD pipelines with Docker Hub.</p>
            <p>The application was successfully built and deployed through:</p>
            <ul>
                <li>GitHub Actions</li>
                <li>GitLab CI</li>
                <li>Bitbucket Pipelines</li>
            </ul>
        </div>
    </body>
    </html>
    '''
    return render_template_string(html)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
