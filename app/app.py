
import json
import re
import time

from datetime import datetime
from flask import Flask, session, url_for, redirect, render_template, request, abort, flash
from db import list_users, verify, delete_user_from_db, add_user, get_users
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_wtf import CSRFProtect
from werkzeug.middleware.proxy_fix import ProxyFix

app = Flask(__name__)
app.config.from_object('config')

# Setup CSRF protection
csrf = CSRFProtect(app)

# Apply ProxyFix middleware to handle X-Forwarded-Proto header from ALB for HTTPS redirects
app.wsgi_app = ProxyFix(app.wsgi_app, x_proto=1)

# Session timeout configuration
SESSION_TIMEOUT = 300  # 5 minutes in seconds

# Setup rate limiter
limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=[]
)

# Dictionary to track failed login attempts per username
failed_login_attempts = {}
LOCKOUT_TIME = 300  # lockout time in seconds (5 minutes)
MAX_ATTEMPTS = 5

try:
    from flask import Markup
except ImportError:
    from markupsafe import Markup

from markupsafe import escape

@app.errorhandler(401)
def FUN_401(error):
    return render_template("page_401.html"), 401

@app.errorhandler(403)
def FUN_403(error):
    return render_template("page_403.html"), 403

@app.errorhandler(404)
def FUN_404(error):
    return render_template("page_404.html"), 404

@app.errorhandler(405)
def FUN_405(error):
    return render_template("page_405.html"), 405

@app.errorhandler(413)
def FUN_413(error):
    return render_template("page_413.html"), 413

@app.route("/")
def FUN_root():
    return render_template("index.html")

@app.route("/health")
def FUN_health():
    return json.dumps({'success':True}), 200, {'ContentType':'application/json'}

@app.route("/metrics")
def FUN_metrics():
    return json.dumps({'success':True}), 200, {'ContentType':'application/json'}

@app.before_request
def session_management():
    if 'current_user' in session:
        now = datetime.utcnow().timestamp()
        last_activity = session.get('last_activity', None)
        if last_activity and (now - last_activity) > SESSION_TIMEOUT:
            session.pop('current_user', None)
            session.pop('last_activity', None)
            flash("Session timed out due to inactivity. Please log in again.")
            return redirect(url_for('FUN_root'))
        else:
            session['last_activity'] = now

@app.route("/users/")
def FUN_user_dashboard():
    if session.get("current_user", None) != None:
        user_list = get_users()
        user_table = zip([x[0] for x in user_list], \
                         [x[1] for x in user_list], \
                         [x[2] for x in user_list], \
                         [x[3] for x in user_list], \
                         [x[4] for x in user_list], \
                         [x[5] for x in user_list], \
                         [x[6] for x in user_list], \
                         [x[7] for x in user_list], \
                         ["/delete_user/" + x[5] for x in user_list])
        return render_template("users.html", users = user_table)
    else:
        return abort(401)

@app.route("/admin/")
def FUN_user_management():
    if session.get("current_user", None) == "admin":
        return render_template("admin.html")
    else:
        return abort(401)


@app.route("/login", methods = ["POST"])
@limiter.limit("10 per minute")
def FUN_login():
    id_submitted = request.form.get("id").lower()

    # Check if user is currently locked out
    if id_submitted in failed_login_attempts:
        attempts, last_attempt_time = failed_login_attempts[id_submitted]
        if attempts >= MAX_ATTEMPTS and (time.time() - last_attempt_time) < LOCKOUT_TIME:
            flash("Account locked due to too many failed login attempts. Please try again later.")
            return redirect(url_for("FUN_root"))
        elif (time.time() - last_attempt_time) >= LOCKOUT_TIME:
            # Reset after lockout period
            failed_login_attempts[id_submitted] = (0, 0)

    if (id_submitted in list_users()) and verify(id_submitted, request.form.get("pw")):
        session['current_user'] = id_submitted
        # Reset failed attempts on successful login
        if id_submitted in failed_login_attempts:
            del failed_login_attempts[id_submitted]
    else:
        # Increment failed attempts
        if id_submitted in failed_login_attempts:
            attempts, _ = failed_login_attempts[id_submitted]
            failed_login_attempts[id_submitted] = (attempts + 1, time.time())
        else:
            failed_login_attempts[id_submitted] = (1, time.time())
        flash("Invalid username or password.")

    return(redirect(url_for("FUN_root")))

@app.route("/logout/")
def FUN_logout():
    session.pop("current_user", None)
    return(redirect(url_for("FUN_root")))

@app.route("/delete_user/<id>/", methods = ['POST'])
def FUN_delete_user(id):
    if session.get("current_user", None) == "admin":
        if id == "admin": # ADMIN account can't be deleted.
            return abort(403)

        safe_id = escape(id)
        delete_user_from_db(safe_id)
        return(redirect(url_for("FUN_user_dashboard")))
    else:
        return abort(401)

def is_valid_username(username):
    # Username must be alphanumeric and 3-100 characters long, dots allowed but not at start/end or consecutive
    return re.match(r'^(?!.*\.\.)(?!\.)(?!.*\.$)[a-zA-Z0-9.]{3,100}$', username) is not None

def is_valid_name(name):
    # Name must be alphabetic and 1-50 characters long
    return re.match(r'^[a-zA-Z0-9]{1,50}$', name) is not None

def is_valid_age(age):
    try:
        age_int = int(age)
        return 0 < age_int < 150
    except:
        return False

@app.route("/add_user", methods = ["POST"])
def FUN_add_user():
    if session.get("current_user", None) == "admin": # only Admin should be able to add user.
        username = request.form.get('username')
        if not username or not is_valid_username(username):
            user_list = list_users()
            user_table = zip(range(1, len(user_list)+1), \
                             user_list, \
                             [x + y for x,y in zip(["/delete_user/"] * len(user_list), user_list)])
            return(render_template("admin.html", id_to_add_is_invalid = True, users = user_table))
        if username.lower() in list_users():
            user_list = list_users()
            user_table = zip(range(1, len(user_list)+1), \
                             user_list, \
                             [x + y for x,y in zip(["/delete_user/"] * len(user_list), user_list)])
            return(render_template("admin.html", id_to_add_is_duplicated = True, users = user_table))
        firstname = request.form.get('firstname')
        lastname = request.form.get('lastname')
        if not is_valid_name(firstname) or not is_valid_name(lastname):
            user_list = list_users()
            user_table = zip(range(1, len(user_list)+1), \
                             user_list, \
                             [x + y for x,y in zip(["/delete_user/"] * len(user_list), user_list)])
            return(render_template("admin.html", name_is_invalid = True, users = user_table))
        age = request.form.get('age')
        if not is_valid_age(age):
            user_list = list_users()
            user_table = zip(range(1, len(user_list)+1), \
                             user_list, \
                             [x + y for x,y in zip(["/delete_user/"] * len(user_list), user_list)])
            return(render_template("admin.html", age_is_invalid = True, users = user_table))
        add_user(
            request.form.get('title'),
            firstname,
            lastname,
            username,
            request.form.get('password'),
            age
        )
        return(redirect(url_for("FUN_user_dashboard")))
    else:
        return abort(401)



if __name__ == "__main__":
    app.run(debug=False, host="0.0.0.0")
