from flask import Flask, render_template, request
import mysql.connector
import re

app = Flask(__name__)
connection = mysql.connector.connect(host='92.52.58.251',
                                     database='iis',
                                     user='admin',
                                     password='password')


#############################################


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/registration', methods=['POST'])
def registration():
    fname = request.form['fname']
    lname = request.form['lname']
    login = request.form['nickname']
    email = request.form['email']
    password = request.form['password']
    passwordConfirm = request.form['passwordConfirm']

    if fname == "" or lname == "" or login == "" or not re.search('(?:[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])', email) or password != passwordConfirm or not re.search('^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{5,30}$', password):
        return render_template('index.html')

    cursor = connection.cursor(buffered=True)
    cursor.execute("SELECT nickname FROM Administrator")
    for (nickname) in cursor:
        if nickname == login:
            cursor.close()
            return render_template('index.html')
    cursor.close()

    query = f"INSERT INTO Administrator (meno, priezvisko, nickname, heslo) VALUES ('{fname}', '{lname}', '{nickname}', '{password}')"
    cursor = connection.cursor()
    cursor.execute(query)
    connection.commit()
    cursor.close()

    return render_template('registrationSuccess.html', data=fname)


@app.route('/preSignIn', methods=['GET', 'POST'])
def preSignIn():
    return render_template('signIn.html')


@app.route('/signIn', methods=['GET', 'POST'])
def signIn():
    nickname1 = str(request.form['nickname'])
    password1 = str(request.form['password'])
    # kontrola spravnosti prihlasovacich udajov z webu a DB
    cursor = connection.cursor(buffered=True)
    cursor.execute("SELECT nickname, heslo FROM Administrator")
    for (nickname, heslo) in cursor:
        if nickname == nickname1 and heslo == password1:
            cursor.close()
            return render_template('signInSuccess.html', data=nickname1)
    cursor.close()
    return render_template('signIn.html')


if __name__ == '__main__':
    app.run(debug=True)
