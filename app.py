from flask import Flask

# Initialize the Flask application
app = Flask(__name__)

# Define a route for the homepage
@app.route('/')
def hello():
    """This function returns a simple greeting string."""
    return "Hello, World! This is the Flask app running in a Docker container."

# Run the app
if __name__ == '__main__':
    # The host '0.0.0.0' makes the app accessible from outside the container
    app.run(host='0.0.0.0', port=80)