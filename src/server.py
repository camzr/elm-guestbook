from flask import Flask, jsonify
from flask_cors import CORS
from datetime import datetime

app = Flask(__name__)
CORS(app)


class Comment:
    def __init__(self, user, comment):
        self.user = user
        self.time = datetime.now()
        self.comment = comment

    def serialize(self):
        return {"user": self.user, "time": self.time, "comment": self.comment}


comments = [
    Comment("user1", "this is a first comment"),
    Comment("user2", "this is a second comment"),
]


@app.route("/", methods=["GET"])
def getcomment():
    global comments
    return jsonify([x.serialize() for x in comments])


@app.route("/simple", methods=["GET"])
def getSimpleComment():
    return jsonify({"comment": "simple comment"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
