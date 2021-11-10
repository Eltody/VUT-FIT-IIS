from flask import Flask, render_template, request
import pymysql
import re

app = Flask(__name__)
connection = pymysql.connect(host='92.52.58.251', user='admin', password='password', db='iis')


#############################################


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/registration', methods=['POST'])
def registration():
    fname = request.form['fname']
    lname = request.form['lname']
    user_email = request.form['email']
    password = request.form['password']
    passwordConfirm = request.form['passwordConfirm']

    if fname == "" or lname == "" or user_email == "" or not re.search(
            '(?:[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])',
            user_email) or password != passwordConfirm or not re.search(
            '^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{5,30}$', password):
        return render_template('index.html')

    cursor = connection.cursor()
    cursor.execute("SELECT email FROM Cestujuci")
    for (email) in cursor:
        email = ''.join(email)
        if email == user_email:
            cursor.close()
            return render_template('index.html')
    cursor.close()

    cursor = connection.cursor()
    cursor.execute("insert into `Cestujuci` (meno, priezvisko, email, heslo) VALUES (%s, %s, %s, %s)", (fname, lname, user_email, password))
    connection.commit()
    cursor.close()

    return render_template('registrationSuccess.html', data=fname)


@app.route('/busConfig', methods=['GET', 'POST'])
def busConfig():
    fromCity = request.form['fromCity']
    toCity = request.form['toCity']
    print(fromCity)
    print(toCity)
    return render_template('index.html')  # vyvolanie main page aby sme na nej pri vyhladavani spoju aj zostali


@app.route('/preSignIn', methods=['GET', 'POST'])
def preSignIn():
    return render_template('signIn.html')


@app.route('/signIn', methods=['GET', 'POST'])
def signIn():
    user_email = str(request.form['email'])
    password1 = str(request.form['password'])
    # kontrola spravnosti prihlasovacich udajov z webu a DB
    cursor = connection.cursor()
    cursor.execute("SELECT meno, email, heslo FROM Cestujuci")
    for (meno, email, heslo) in cursor:
        if email == user_email and heslo == password1:
            cursor.close()
            return render_template('signInSuccess.html', data=meno)
    cursor.close()
    return render_template('signIn.html')


if __name__ == '__main__':
    app.run(debug=True)
