from flask import Flask, render_template, request
import pymysql

app = Flask(__name__)
connection = pymysql.connect(host='92.52.58.251', user='admin', password='password', db='iis')
emails = []


#############################################
@app.route('/')
def index():
    cursor = connection.cursor()
    cursor.execute("SELECT nazov_zastavky from Zastavky")
    tmp = cursor.fetchall()
    cursor.close()
    cities = []
    for i in tmp:
        cities.append(''.join(i))
    cities = sorted(cities)
    return render_template("index.html", cities=cities, data="")


@app.route('/busConfig', methods=['GET', 'POST'])
def busConfig():
    fromCity = request.form['fromCity']
    toCity = request.form['toCity']
    #TODO connect to database, return list of connections
    #TODO list connections
    return render_template('busList.html')


@app.route('/preSignIn', methods=['GET', 'POST'])
def preSignIn():
    return render_template('signIn.html', data="")


@app.route('/signIn', methods=['GET', 'POST'])
def signIn():
    user_email = str(request.form['lEmail'])
    password = str(request.form['lPassword'])
    # kontrola spravnosti prihlasovacich udajov z webu a DB
    cestujuci = connection.cursor()
    administrator = connection.cursor()
    personal = connection.cursor()
    cestujuci.execute("SELECT meno, email, heslo FROM Cestujuci")
    administrator.execute("SELECT meno, email, heslo FROM Administrator")
    personal.execute("SELECT meno, email, heslo FROM Personal")
    for (meno, email, heslo) in cestujuci:
        if email == user_email and heslo == password:
            cestujuci.close()
            return render_template('index.html', data=meno)
    for (meno, email, heslo) in administrator:
        if email == user_email and heslo == password:
            administrator.close()
            data = {'message': 'login', 'name': meno}
            return render_template('index.html', data=meno)
    for (meno, email, heslo) in personal:
        if email == user_email and heslo == password:
            personal.close()
            return render_template('index.html', data=meno)
    cestujuci.close()
    administrator.close()
    personal.close()

#    if user_email == emails[0]:
#        if user_email == emails[1]:
#            if user_email == emails[2]:
#                #TODO email sending
#            elif emails[2] == '':
#                emails.append(user_email)
#            else:
#                emails.clear()
#                emails.append(user_email)
#        elif emails[1] == '':
#            emails.append(user_email)
#        else:
#            emails.clear()
#            emails.append(user_email)
#    elif emails[0] == '':
#        emails.append(user_email)
#    else:
#        emails.clear()
#        emails.append(user_email)
    data = {'error': 'log', 'email': user_email}
    return render_template('signIn.html', data=data)


@app.route('/registration', methods=['POST'])
def registration():
    fname = request.form['fname']
    lname = request.form['lname']
    user_email = request.form['email']
    password = request.form['password']

    cursor = connection.cursor()
    cursor.execute("SELECT email FROM Cestujuci")
    for (email) in cursor:
        email = ''.join(email)
        if email == user_email:
            cursor.close()
            data = {'error': 'reg', 'email': user_email}
            return render_template('signIn.html', data=data)
    cursor.close()

    cursor = connection.cursor()
    cursor.execute("insert into `Cestujuci` (meno, priezvisko, email, heslo) VALUES (%s, %s, %s, %s)", (fname, lname, user_email, password))
    connection.commit()
    cursor.close()

    return render_template('registrationSuccess.html', data=fname)


if __name__ == '__main__':
    app.run(debug=True)
