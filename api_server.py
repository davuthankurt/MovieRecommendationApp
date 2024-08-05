from flask import Flask, request, jsonify
import subprocess
import sys
import json

app = Flask(__name__)

@app.route('/recommend/content', methods=['POST'])
def contentbased_recommend():
    try:
        user_input = request.json.get('userInput')
        if not user_input:
            return jsonify({'error': 'userInput is required'}), 400

        
        result = subprocess.run([sys.executable, 'content_based.py', json.dumps(user_input)], capture_output=True, text=True)

        if result.returncode != 0:
            return jsonify({'error': 'Error executing content-based script', 'details': result.stderr}), 500

        output = json.loads(result.stdout)
        return jsonify({'ordered_recommended_movies': output})
    except Exception as e:
        return jsonify({'error': str(e)})


@app.route('/recommend/collaborative', methods=['POST'])
def collaborative_recommend():
    try:
        user_input = request.json.get('userInput')
        if not user_input:
            return jsonify({'error': 'userInput is required'}), 400

        
        result = subprocess.run([sys.executable, 'collaborative_filtering.py', json.dumps(user_input)], capture_output=True, text=True)

        if result.returncode != 0:
            return jsonify({'error': 'Error executing collaborative filtering script', 'details': result.stderr}), 500

        output = json.loads(result.stdout)
        return jsonify({'ordered_recommended_movies': output})
    except Exception as e:
        return jsonify({'error': str(e)})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)


