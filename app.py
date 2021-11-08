from flask import Flask, render_template, request
import mysql.connector

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
    nickname = request.form['nickname']
    password = request.form['password']
    passwordConfirm = request.form['passwordConfirm']

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
