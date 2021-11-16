from flask import Flask, render_template, request
import pymysql

app = Flask(__name__)
connection = pymysql.connect(host='92.52.58.251', user='admin', password='password', db='iis')
emails = []
loginData = {}
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
    return render_template("index.html", cities=cities, data=loginData)

@app.route('/busConfig', methods=['GET', 'POST'])
def busConfig():
    fromCity = request.form['fromCity']
    toCity = request.form['toCity']
    timeFromDate = request.form['date']

    # ziskanie id fromCity a toCity
    cursor1 = connection.cursor()
    cursor2 = connection.cursor()
    cursor1.execute("SELECT id FROM Zastavky WHERE nazov_zastavky='%s';" % fromCity)
    cursor2.execute("SELECT id FROM Zastavky WHERE nazov_zastavky='%s';" % toCity)
    id_fromCity = cursor1.fetchone()
    id_toCity = cursor2.fetchone()
    cursor1.close()
    cursor2.close()
    id_fromCity = str(id_fromCity[0])    # id mesta, z ktoreho cestujem
    id_toCity = str(id_toCity[0])        # id mesta, do ktoreho cestujem

    # ziskanie casov prejazdov z jednotlivych miest podla id fromCity a toCity
    cursor1 = connection.cursor()
    cursor2 = connection.cursor()
    cursor1.execute("SELECT cas_prejazdu, id_spoju FROM Spoj_Zastavka WHERE id_zastavky='%s';" % id_fromCity)
    cursor2.execute("SELECT cas_prejazdu, id_spoju FROM Spoj_Zastavka WHERE id_zastavky='%s';" % id_toCity)
    possibilities_fromCity = cursor1.fetchall()
    possibilities_toCity = cursor2.fetchall()
    cursor1.close()
    cursor2.close()

    # ziskanie konkretneho casu pre vyhladanie najblizsich spojeni
    timeFromDate = timeFromDate.rsplit('T', 1)         # splitnutie na datum [0] a cas [1]
    timeFromDate = timeFromDate[1].replace(":", "")    # odstranenie ':' pre prevod na int
    timeFromDate = int(timeFromDate)    # string to int pre porovanie casov

    #### VYSVETLENIE PREMENNYCH ####
    # fromCity - mesto, odkial cestujem
    # toCity - mesto, kam cestujem
    # possibilities_fromCity - casy prejazdov z mesta, odkial cestujem, s id_spojom
    # possibilities_toCity - casy prejazdov z mesta, kam cestujem, s id_spojom
    # timeFromDate - konkretny cas zadany uzivatelom vo vyhladavani spojov

    # ziskanie len vyhovujucich spojov - rovnake id_spoju pre fromCity a toCity
    possibleBusConnections = []
    for row1 in possibilities_fromCity:
        for row2 in possibilities_toCity:
            if row1[1] == row2[1]:  # rovnanie cisla spojov v jednotlivych casoch prejazdov
                tmp_timeFromCity = str(row1[0]) # array to string
                tmp_timeToCity = str(row2[0])
                tmp_timeFromCity = tmp_timeFromCity.replace(":", "")    # odstranenie ':' pre porovnanie casov
                tmp_timeToCity = tmp_timeToCity.replace(":", "")
                tmp_timeFromCity = int(tmp_timeFromCity)    # string to int
                tmp_timeToCity = int(tmp_timeToCity)
                if tmp_timeFromCity < tmp_timeToCity:
                    cursor1 = connection.cursor()
                    cursor1.execute("SELECT id_dopravca_spoje FROM Spoj WHERE id='%s';" % row1[1])
                    id_dopravca = cursor1.fetchone()    # ziskanie id_dopravcu_spoje
                    cursor1.close()
                    cursor1 = connection.cursor()
                    cursor1.execute("SELECT meno, priezvisko FROM Dopravca WHERE id='%s';" % id_dopravca)
                    carrier_name = cursor1.fetchone()  # ziskanie id_dopravcu_spoje
                    cursor1.close()
                    fromCityTime = row1[0]
                    toCityTime = row2[0]
                    connectionNumber = row1[1]
                    carrier_name = carrier_name[0] + carrier_name[1]  # spojenie meno a priezvisko do jedneho
                    if tmp_timeFromCity > timeFromDate: # porovnanie casu odchodu a zvoleneho casu uzivatelom pre najblizsie spoje
                        possibleBusConnections.append([connectionNumber, fromCity, fromCityTime, toCity, toCityTime, carrier_name])
    print(possibleBusConnections)
    # possibleBusConnections - vo formate: cislo_spoju, fromCity, cas_prejazdu(fromCity), toCity, cas_prejazdu(toCity), dopravca

    return render_template('connections.html')


@app.route('/preSignIn', methods=['GET', 'POST'])
def preSignIn():
    return render_template('signIn.html', data="")


@app.route('/signIn', methods=['GET', 'POST'])
def signIn():
    global loginData
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
            loginData = {'message': 'login', 'name': meno}
            return index()
    for (meno, email, heslo) in administrator:
        if email == user_email and heslo == password:
            administrator.close()
            loginData = {'message': 'login', 'name': meno}
            return index()
    for (meno, email, heslo) in personal:
        if email == user_email and heslo == password:
            personal.close()
            loginData = {'message': 'login', 'name': meno}
            return index()
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
    global loginData
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

    loginData = {'message': 'login', 'name': fname}
    return index()

@app.route('/signOut')
def signOut():
    loginData.clear()
    return index()

if __name__ == '__main__':
    app.run(debug=True)
