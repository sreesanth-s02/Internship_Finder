# backend/models.py
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class Users(db.Model):
    __tablename__ = "users"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(150), nullable=False)
    email = db.Column(db.String(200), unique=True, nullable=False, index=True)
    phone = db.Column(db.String(50), nullable=True)
    password = db.Column(db.String(200), nullable=False)

    # New fields for profile/auth
    token = db.Column(db.String(200), unique=True, index=True, nullable=True)   # simple dev token
    org = db.Column(db.String(200), nullable=True)           # college/company name
    profile_pic = db.Column(db.String(300), nullable=True)   # relative URL or path
    applied_count = db.Column(db.Integer, default=0)

    def __repr__(self):
        return f"<User {self.id} {self.email}>"

class Internships(db.Model):
    __tablename__ = "internships"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=True)
    domains = db.Column(db.String(500), nullable=True)
    skills = db.Column(db.String(500), nullable=True)
    paid = db.Column(db.String(50), nullable=True)  # yes/no or boolean as strings
    duration = db.Column(db.String(100), nullable=True)
    role = db.Column(db.String(200), nullable=True)
    location = db.Column(db.String(200), nullable=True)
    mode = db.Column(db.String(100), nullable=True)
    prerequisites = db.Column(db.String(500), nullable=True)
    stipend = db.Column(db.String(100), nullable=True)
    other = db.Column(db.String(500), nullable=True)

    def __repr__(self):
        return f"<Internship {self.id} {self.name}>"

class Applications(db.Model):
    __tablename__ = "applications"
    id = db.Column(db.Integer, primary_key=True)
    internship_id = db.Column(db.Integer, nullable=False)
    name = db.Column(db.String(200), nullable=False)
    email = db.Column(db.String(200), nullable=False)
    country = db.Column(db.String(200), nullable=True)
    age = db.Column(db.Integer, nullable=True)
    college_name = db.Column(db.String(300), nullable=True)

    def __repr__(self):
        return f"<Application {self.id} internship:{self.internship_id}>"
