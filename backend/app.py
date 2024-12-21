from flask import Flask, jsonify
import sqlite3

app = Flask(__name__)

@app.route('/get-quiz/<difficulty>', methods=['GET'])
def get_quiz(difficulty):
    # Simuler des questions
    questions = [
        {"id": 1, "question": "What is 2 + 2?", "correct_answer": "4", "difficulty": "easy"},
        {"id": 2, "question": "Capital of France?", "correct_answer": "Paris", "difficulty": "easy"}
    ]
    return jsonify({"questions": questions})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
