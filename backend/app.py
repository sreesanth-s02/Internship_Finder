# backend/app.py
import os
import uuid
import random
import smtplib
from datetime import datetime, timedelta
from email.message import EmailMessage

from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from sqlalchemy import func, or_

from models import db, Users, Internships, Applications

app = Flask(__name__, static_folder=None)

# Allow all origins for dev
CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)

# ---------------------------
# DATABASE PATH
# ---------------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "database.db")
print("Using database:", DB_PATH)

app.config["SQLALCHEMY_DATABASE_URI"] = f"sqlite:///{DB_PATH}"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db.init_app(app)
with app.app_context():
    db.create_all()

# ---------------------------
# Upload folder (dev)
# ---------------------------
UPLOAD_FOLDER = os.path.join(BASE_DIR, "uploads")
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# ---------------------------
# EMAIL CONFIG (GMAIL SMTP)
# ---------------------------
EMAIL_USER = os.getenv("EMAIL_USER")
EMAIL_PASS = os.getenv("EMAIL_PASS")


def send_email_otp(to_email, otp):
    if not EMAIL_USER or not EMAIL_PASS:
        print("\n❗ EMAIL ERROR: Missing EMAIL_USER or EMAIL_PASS env vars\n")
        return False

    try:
        msg = EmailMessage()
        msg["Subject"] = "Your OTP Verification Code"
        msg["From"] = EMAIL_USER
        msg["To"] = to_email
        msg.set_content(
            f"Your verification OTP is: {otp}\n\nThis code will expire in 5 minutes."
        )

        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.starttls()
        server.login(EMAIL_USER, EMAIL_PASS)
        server.send_message(msg)
        server.quit()
        return True
    except Exception as e:
        print("SMTP ERROR:", e)
        return False


# ---------------------------
# TEMP OTP STORAGE (in-memory)
# ---------------------------
pending_register_otps = {}  # email -> {otp, expires}
pending_login_otps = {}     # email -> {otp, expires}
login_temp_tokens = {}    
pending_password_otps = {} # tempToken -> email

# ---------------------------
# Helper: Convert internship row
# ---------------------------
def internship_to_dict(i: Internships):
    return {
        "id": i.id,
        "name": getattr(i, "name", None) or "",
        "domains": i.domains,
        "skills": i.skills,
        "paid": i.paid,
        "duration": i.duration,
        "role": i.role,
        "location": i.location,
        "mode": i.mode,
        "prerequisites": i.prerequisites,
        "stipend": i.stipend,
        "other": i.other,
    }


# ---------------------------
# Helper: Serialize user for frontend  (fixed indentation)
# ---------------------------
def _user_to_dict(u: Users):
    org = getattr(u, "org", None) or getattr(u, "organization", None) or ""
    profile_pic = getattr(u, "profile_pic", None) or None

    # always recompute from Applications to be safe
    try:
        applied_count = Applications.query.filter_by(email=u.email).count()
    except Exception:
        applied_count = getattr(u, "applied_count", 0) or 0

    # keep DB column roughly in sync (optional)
    if hasattr(u, "applied_count") and u.applied_count != applied_count:
        u.applied_count = applied_count
        try:
            db.session.commit()
        except Exception:
            pass

    return {
        "id": u.id,
        "username": u.username,
        "email": u.email,
        "phone": u.phone or "",
        "org": org,
        "profile_pic": profile_pic,
        "applied_count": applied_count or 0,
    }


# ---------------------------
# Simple token handling helper
# ---------------------------
DEV_TOKEN = "dev-token-12345"


def set_user_token(user: Users, token_value: str):
    if hasattr(user, "token"):
        setattr(user, "token", token_value)
        db.session.commit()
        return True
    return False


def get_user_from_token_header(auth_header: str):
    """Return Users instance matching Bearer token, or None"""
    if not auth_header:
        return None
    parts = auth_header.split()
    if len(parts) != 2 or parts[0].lower() != "bearer":
        return None
    token = parts[1]

    # first try model token field if exists
    if hasattr(Users, "token"):
        u = Users.query.filter_by(token=token).first()
        if u:
            return u

    # fallback to DEV_TOKEN -> return the first user for dev convenience
    if token == DEV_TOKEN:
        return Users.query.first()

    return None


# ---------------------------
# Legacy routes (unchanged)
# ---------------------------

# Register (legacy)
@app.route("/register", methods=["POST"])
def register():
    data = request.get_json(silent=True) or {}

    username = (data.get("username") or "").strip()
    email = (data.get("email") or "").strip().lower()
    phone = data.get("phone")
    password = (data.get("password") or "").strip()

    if not username or not email or not password:
        return (
            jsonify(
                {
                    "success": False,
                    "message": "username, email & password required",
                }
            ),
            400,
        )

    if Users.query.filter_by(email=email).first():
        return jsonify({"success": False, "message": "Email already exists"}), 200

    user = Users(username=username, email=email, phone=phone, password=password)
    db.session.add(user)
    db.session.commit()

    return jsonify({"success": True, "message": "User registered successfully"}), 200


# Login (legacy)
@app.route("/login", methods=["POST"])
def login():
    data = request.get_json(silent=True) or {}

    email = (data.get("email") or "").strip().lower()
    password = (data.get("password") or "").strip()

    if not email or not password:
        return (
            jsonify({"success": False, "message": "email and password required"}),
            400,
        )

    user = Users.query.filter_by(email=email).first()

    if not user or user.password != password:
        return jsonify({"success": False, "message": "Invalid credentials"}), 200

    return (
        jsonify(
            {
                "success": True,
                "message": "Login successful",
                "user": {
                    "id": user.id,
                    "username": user.username,
                    "email": user.email,
                },
            }
        ),
        200,
    )


# Get all internships
@app.route("/internships", methods=["GET"])
def get_internships():
    internships = Internships.query.all()
    data = [internship_to_dict(i) for i in internships]
    return jsonify({"success": True, "count": len(data), "results": data}), 200


# Get internship by ID
@app.route("/internships/<int:internship_id>", methods=["GET"])
def internship_by_id(internship_id):
    i = Internships.query.get(internship_id)
    if not i:
        return jsonify({"success": False, "message": "Internship not found"}), 404
    return jsonify({"success": True, "internship": internship_to_dict(i)}), 200


# Search internships
@app.route("/internships/search", methods=["POST"])
def internship_search():
    filters = request.get_json(silent=True) or {}

    domain_filters = filters.get("domain")
    skill_filters = filters.get("skill")
    location = filters.get("location")
    mode = filters.get("mode")
    paid = filters.get("paid")

    page = int(filters.get("page", 1))
    page_size = int(filters.get("page_size", 20))
    offset = (page - 1) * page_size

    query = Internships.query

    if domain_filters:
        if isinstance(domain_filters, list):
            conditions = [
                func.lower(Internships.domains).like(f"%{d.lower()}%")
                for d in domain_filters
            ]
            query = query.filter(or_(*conditions))
        else:
            query = query.filter(
                func.lower(Internships.domains).like(f"%{domain_filters.lower()}%")
            )

    if skill_filters:
        if isinstance(skill_filters, list):
            conditions = [
                func.lower(Internships.skills).like(f"%{s.lower()}%")
                for s in skill_filters
            ]
            query = query.filter(or_(*conditions))
        else:
            query = query.filter(
                func.lower(Internships.skills).like(f"%{skill_filters.lower()}%")
            )

    if location:
        query = query.filter(
            func.lower(Internships.location).like(f"%{location.lower()}%")
        )

    if mode:
        query = query.filter(func.lower(Internships.mode).like(f"%{mode.lower()}%"))

    if paid:
        query = query.filter(func.lower(Internships.paid).like(f"%{paid.lower()}%"))

    total = query.count()
    rows = query.offset(offset).limit(page_size).all()
    results = [internship_to_dict(r) for r in rows]

    return jsonify({"success": True, "count": total, "results": results}), 200


# SIMPLE APPLY (matches your DB) + bump applied_count
@app.route("/apply", methods=["POST"])
def apply():
    data = request.get_json(silent=True) or {}

    # Only these are strictly required:
    required = ["internship_id", "name", "email"]
    for f in required:
        if not data.get(f):
            return jsonify({"success": False, "message": f"{f} is required"}), 400

    # Optional fields with safe defaults
    country = data.get("country") or "Not specified"
    try:
        age = int(data.get("age") or 0)
    except Exception:
        age = 0

    application = Applications(
        internship_id=int(data["internship_id"]),
        name=data["name"],
        email=data["email"],
        country=country,
        age=age,
        college_name=data.get("college_name"),
    )

    db.session.add(application)

    # update user's applied_count, if that email exists
    try:
        email = (data["email"] or "").strip().lower()
        user = Users.query.filter(func.lower(Users.email) == email).first()
        if user:
            if user.applied_count is None:
                user.applied_count = 1
            else:
                user.applied_count = int(user.applied_count) + 1
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        print("WARN: application saved but failed to bump applied_count:", e)
        return jsonify({"success": True, "message": "Application submitted"}), 200

    return jsonify({"success": True, "message": "Application submitted"}), 200


# ---------------------------------------------------------------
# DEV compatibility endpoints for frontend (API-style)
# ---------------------------------------------------------------
@app.route("/api/auth/register", methods=["POST"])
def api_auth_register():
    data = request.get_json(silent=True) or {}
    username = (data.get("username") or "").strip()
    email = (data.get("email") or "").strip().lower()
    phone = data.get("phone")
    password = (data.get("password") or "").strip()

    if not username or not email or not password:
        return (
            jsonify(
                {
                    "success": False,
                    "message": "username, email & password required",
                }
            ),
            400,
        )

    if Users.query.filter_by(email=email).first():
        return jsonify({"success": False, "message": "Email already exists"}), 409

    user = Users(username=username, email=email, phone=phone, password=password)
    db.session.add(user)
    db.session.commit()

    token_value = str(uuid.uuid4())
    if not set_user_token(user, token_value):
        token_value = DEV_TOKEN

    return (
        jsonify(
            {
                "success": True,
                "message": "User registered",
                "token": token_value,
                "user": _user_to_dict(user),
            }
        ),
        200,
    )


@app.route("/api/auth/login", methods=["POST"])
def api_auth_login():
    data = request.get_json(silent=True) or {}
    email = (data.get("email") or "").strip().lower()
    password = (data.get("password") or "").strip()

    if not email or not password:
        return (
            jsonify({"success": False, "message": "email and password required"}),
            400,
        )

    user = Users.query.filter_by(email=email).first()
    if not user or user.password != password:
        return jsonify({"success": False, "message": "Invalid credentials"}), 401

    token_value = str(uuid.uuid4())
    if not set_user_token(user, token_value):
        token_value = DEV_TOKEN

    return (
        jsonify(
            {
                "success": True,
                "message": "Login successful",
                "token": token_value,
                "user": _user_to_dict(user),
            }
        ),
        200,
    )


@app.route("/api/me", methods=["GET"])
def api_me_get():
    auth = request.headers.get("Authorization", "")
    user = get_user_from_token_header(auth)
    if not user:
        return jsonify({"success": False, "message": "Unauthorized"}), 401
    return jsonify(_user_to_dict(user)), 200


@app.route("/api/me", methods=["PUT", "POST"])
def api_me_update():
    auth = request.headers.get("Authorization", "")
    user = get_user_from_token_header(auth)
    if not user:
        return jsonify({"success": False, "message": "Unauthorized"}), 401

    if request.is_json:
        data = request.get_json(silent=True) or {}
    else:
        data = request.form.to_dict() or {}

    if "username" in data:
        user.username = data["username"]
    if "phone" in data:
        user.phone = data["phone"]
    if "org" in data:
        if hasattr(user, "org"):
            setattr(user, "org", data["org"])
        elif hasattr(user, "organization"):
            setattr(user, "organization", data["org"])

    db.session.commit()
    return jsonify({"success": True, "user": _user_to_dict(user)}), 200


@app.route("/api/me/picture", methods=["PUT", "POST"])
def api_me_upload_pic():
    auth = request.headers.get("Authorization", "")
    user = get_user_from_token_header(auth)
    if not user:
        return jsonify({"success": False, "message": "Unauthorized"}), 401

    if "profile_pic" not in request.files:
        return jsonify({"success": False, "message": "No file uploaded"}), 400

    f = request.files["profile_pic"]
    if not f or f.filename == "":
        return jsonify({"success": False, "message": "Empty filename"}), 400

    ext = os.path.splitext(f.filename)[1] or ".jpg"
    filename = f"user_{user.id}_{uuid.uuid4().hex}{ext}"
    path = os.path.join(UPLOAD_FOLDER, filename)
    f.save(path)

    if hasattr(user, "profile_pic"):
        user.profile_pic = f"/uploads/{filename}"
        db.session.commit()

    return jsonify({"success": True, "profile_pic": f"/uploads/{filename}"}), 200


@app.route("/uploads/<path:filename>")
def uploaded_file(filename):
    return send_from_directory(UPLOAD_FOLDER, filename)

# ---------------------------------------------------------------
# ✅ NEW OTP ENDPOINTS — Registration
# ---------------------------------------------------------------
@app.route("/otp/register/request", methods=["POST"])
def otp_register_request():
    data = request.get_json(silent=True) or {}
    email = (data.get("email") or "").strip().lower()

    if not email:
        return jsonify({"success": False, "message": "Email required"}), 400

    if Users.query.filter_by(email=email).first():
        return jsonify({"success": False, "message": "Email already exists"}), 409

    otp = random.randint(100000, 999999)
    pending_register_otps[email] = {
        "otp": str(otp),
        "expires": datetime.utcnow() + timedelta(minutes=5),
    }

    sent = send_email_otp(email, otp)
    if not sent:
        return jsonify({"success": False, "message": "Failed to send email"}), 500

    return jsonify({"success": True}), 200


@app.route("/otp/register/verify", methods=["POST"])
def otp_register_verify():
    data = request.get_json(silent=True) or {}
    email = (data.get("email") or "").strip().lower()
    otp = (data.get("otp") or "").strip()

    rec = pending_register_otps.get(email)
    if not rec:
        return jsonify({"success": False, "message": "OTP not requested"}), 400

    if datetime.utcnow() > rec["expires"]:
        return jsonify({"success": False, "message": "OTP expired"}), 400

    if rec["otp"] != otp:
        return jsonify({"success": False, "message": "Invalid OTP"}), 400

    username = data.get("username")
    phone = data.get("phone")
    password = data.get("password")

    user = Users(username=username, email=email, phone=phone, password=password)
    db.session.add(user)
    db.session.commit()

    token_value = str(uuid.uuid4())
    user.token = token_value
    db.session.commit()

    pending_register_otps.pop(email, None)

    return (
        jsonify({"success": True, "token": token_value, "user": _user_to_dict(user)}),
        200,
    )

# ---------------------------------------------------------------
# ✅ NEW OTP ENDPOINTS — Login
# ---------------------------------------------------------------
@app.route("/otp/login/request", methods=["POST"])
def otp_login_request():
    data = request.get_json(silent=True) or {}
    email = (data.get("email") or "").strip().lower()
    password = (data.get("password") or "").strip()

    user = Users.query.filter_by(email=email).first()
    if not user or user.password != password:
        return jsonify({"success": False, "message": "Invalid credentials"}), 401

    otp = random.randint(100000, 999999)
    temp_token = uuid.uuid4().hex

    pending_login_otps[email] = {
        "otp": str(otp),
        "expires": datetime.utcnow() + timedelta(minutes=5),
    }
    login_temp_tokens[temp_token] = email

    send_email_otp(email, otp)

    return jsonify({"success": True, "tempToken": temp_token}), 200


@app.route("/otp/login/verify", methods=["POST"])
def otp_login_verify():
    data = request.get_json(silent=True) or {}
    temp = data.get("tempToken")
    otp = (data.get("otp") or "").strip()

    email = login_temp_tokens.get(temp)
    if not email:
        return jsonify({"success": False, "message": "Invalid temp token"}), 400

    rec = pending_login_otps.get(email)
    if not rec:
        return jsonify({"success": False, "message": "OTP not requested"}), 400

    if datetime.utcnow() > rec["expires"]:
        return jsonify({"success": False, "message": "OTP expired"}), 400

    if rec["otp"] != otp:
        return jsonify({"success": False, "message": "Invalid OTP"}), 400

    user = Users.query.filter_by(email=email).first()
    token_value = str(uuid.uuid4())
    user.token = token_value
    db.session.commit()

    pending_login_otps.pop(email, None)
    login_temp_tokens.pop(temp, None)

    return (
        jsonify({"success": True, "token": token_value, "user": _user_to_dict(user)}),
        200,
    )
    # ---------------------------------------------------------------
# OTP endpoints — Forgot Password
# ---------------------------------------------------------------
@app.route("/otp/password/request", methods=["POST"])
def otp_password_request():
    data = request.get_json(silent=True) or {}
    email = (data.get("email") or "").strip().lower()

    if not email:
        return jsonify({"success": False, "message": "Email required"}), 400

    user = Users.query.filter_by(email=email).first()
    if not user:
        # Don't reveal if email exists or not (security best practice),
        # but for your project we can give a hint if you want.
        return jsonify({"success": False, "message": "No account with this email"}), 404

    otp = random.randint(100000, 999999)
    pending_password_otps[email] = {
        "otp": str(otp),
        "expires": datetime.utcnow() + timedelta(minutes=5),
    }

    sent = send_email_otp(email, otp)
    if not sent:
        return jsonify({"success": False, "message": "Failed to send email"}), 500

    return jsonify({"success": True}), 200

@app.route("/", methods=["GET"])
def index():
    return {
        "success": True,
        "message": "InternConnect backend is running",
        "endpoints": [
            "/internships",
            "/internships/search",
            "/apply",
            "/api/auth/login",
            "/api/auth/register",
        ],
    }, 200



@app.route("/otp/password/reset", methods=["POST"])
def otp_password_reset():
    data = request.get_json(silent=True) or {}
    email = (data.get("email") or "").strip().lower()
    otp = (data.get("otp") or "").strip()
    new_password = (data.get("new_password") or "").strip()

    if not email or not otp or not new_password:
        return jsonify({"success": False, "message": "Missing fields"}), 400

    rec = pending_password_otps.get(email)
    if not rec:
        return jsonify({"success": False, "message": "OTP not requested"}), 400

    if datetime.utcnow() > rec["expires"]:
        return jsonify({"success": False, "message": "OTP expired"}), 400

    if rec["otp"] != otp:
        return jsonify({"success": False, "message": "Invalid OTP"}), 400

    user = Users.query.filter_by(email=email).first()
    if not user:
        return jsonify({"success": False, "message": "User not found"}), 404

    # For now we keep plain-text password (same as your current logic).
    user.password = new_password
    db.session.commit()

    # Clear used OTP
    pending_password_otps.pop(email, None)

    return jsonify({"success": True, "message": "Password updated"}), 200



# ---------------------------
# RUN SERVER
# ---------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
