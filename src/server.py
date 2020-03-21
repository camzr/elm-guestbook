from flask import Flask, jsonify, request
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


comments = []


@app.route("/", methods=["GET"])
def getcomment():
    global comments
    return jsonify([x.serialize() for x in comments])


@app.route("/", methods=["POST"])
def postcomment():
    args = request.json
    user = args.get("user")
    comment = args.get("comment")
    global comments
    comments.append(Comment(user, comment))
    return "done", 200


@app.route("/simple", methods=["GET"])
def getSimpleComment():
    return jsonify({"comment": "simple comment"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
