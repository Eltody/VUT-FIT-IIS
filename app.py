from flask import Flask, render_template, request
import time
import json
import pymysql  # pip install pymysql
import datetime  # pip install datetime
import requests  # pip install requests
import threading

app = Flask(__name__)
try:
    connection = pymysql.connect(host='92.52.58.251', user='admin', password='password', db='iis')
except pymysql.Error as error:
    webhookUrl = 'https://maker.ifttt.com/trigger/error/with/key/jglncn-jhDn3EyEKlB3nkuB2VDNC8Rs4Fuxg5IpNE4'
    requests.post(webhookUrl, headers={'Content-Type': 'application/json'})
    print("Cannot connect to database. Error: " + str(error))
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
    data = loginData.copy()
    loginData.clear()
    return render_template("index.html", cities=cities, data=data)


@app.route('/search/<boolLoadMore>/<lastConnectionOnWeb>', methods=['GET', 'POST'])
def search(boolLoadMore, lastConnectionOnWeb):
    if boolLoadMore == 'connections':  # bezne volanie funkcie search - prve volanie tejto funkcie (connections len preto aby dobre vyzerala URL)
        fromCity = request.form['fromCity']
        toCity = request.form['toCity']
        timeFromDate = request.form['date']
    else:  # z funkcie LoadMore: nacitanie dalsich spojov, lastConnectionOnWeb je posledny zobrazeny prvok na stranke
        lastConnectionOnWeb = lastConnectionOnWeb[
                              1:-1]  # KEBY NIECO NEFUNGOVALO TAK ZMENIT ELSE: NA ELIF BOOLLOADMORE == True:
        lastConnectionOnWeb = lastConnectionOnWeb.split(',')
        fromCity = lastConnectionOnWeb[1]
        toCity = lastConnectionOnWeb[3]
        timeFromDate = lastConnectionOnWeb[2]

    # ziskanie id fromCity a toCity
    cursor1 = connection.cursor()
    cursor2 = connection.cursor()
    cursor1.execute("SELECT id FROM Zastavky WHERE nazov_zastavky='%s';" % fromCity)
    cursor2.execute("SELECT id FROM Zastavky WHERE nazov_zastavky='%s';" % toCity)
    id_fromCity = cursor1.fetchone()
    id_toCity = cursor2.fetchone()
    cursor1.close()
    cursor2.close()
    id_fromCity = str(id_fromCity[0])  # id mesta, z ktoreho cestujem
    id_toCity = str(id_toCity[0])  # id mesta, do ktoreho cestujem

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
    if boolLoadMore == 'connections':
        timeFromDate = timeFromDate.rsplit('T', 1)  # splitnutie na datum [0] a cas [1]
        tmp_dateOfConnection = timeFromDate[0]  # datum daneho spoju
        timeFromDate = timeFromDate[1].replace(":", "")  # odstranenie ':' pre prevod na int
    else:
        timeFromDate = timeFromDate.replace(":", "")  # odstranenie ':' pre prevod na int
        splittedDate = lastConnectionOnWeb[7].split('.')  # den [0], mesiac [1], konkretny den v tyzdni [2]
        tmp_dateOfConnection = '2021-' + splittedDate[1] + '-' + splittedDate[0]
    timeFromDate = int(timeFromDate)  # string to int pre porovanie casov

    #### VYSVETLENIE PREMENNYCH ####
    # fromCity - mesto, odkial cestujem
    # toCity - mesto, kam cestujem
    # possibilities_fromCity - casy prejazdov z mesta, odkial cestujem, s id_spojom
    # possibilities_toCity - casy prejazdov z mesta, kam cestujem, s id_spojom
    # timeFromDate - konkretny cas zadany uzivatelom vo vyhladavani spojov

    # ziskanie len vyhovujucich spojov - rovnake id_spoju pre fromCity a toCity
    possibleBusConnections = []
    laterPossibleBusConnections = []
    nextDay = False  # priznak pre opatovne vykovanie celeho cyklu, ale pre dalsi den spojeni
    counterOfConnections = 0  # counter pre pocet spojov zobrazenych sa jednu stranku
    for x in range(2):
        if x == 1:  # druhe vykonanie for cyklu - druhe hladanie v databazi - rovnake, len datum sa zvysi o 1
            nextDay = True
        for row1 in possibilities_fromCity:
            if counterOfConnections >= 5:
                continue
            for row2 in possibilities_toCity:
                if counterOfConnections >= 5:
                    continue
                if row1[1] == row2[1]:  # rovnanie cisla spojov v jednotlivych casoch prejazdov pre vyber z DB
                    tmp_timeFromCity = str(row1[0])  # array to string
                    tmp_timeToCity = str(row2[0])
                    tmp_secsTimeFromCity = str(
                        row1[0])  # premenna pre prevod casu na sekundy kvoli vypoctu trvania cesty
                    tmp_secsTimeToCity = str(row2[0])  # premenna pre prevod casu na sekundy kvoli vypoctu trvania cesty
                    tmp_timeFromCity = tmp_timeFromCity.replace(":", "")  # odstranenie ':' pre porovnanie casov
                    tmp_timeToCity = tmp_timeToCity.replace(":", "")
                    tmp_timeFromCity = int(tmp_timeFromCity)  # string to int
                    tmp_timeToCity = int(tmp_timeToCity)
                    if tmp_timeFromCity < tmp_timeToCity:
                        cursor1 = connection.cursor()
                        cursor1.execute("SELECT id_dopravca_spoje FROM Spoj WHERE id='%s';" % row1[1])
                        id_dopravca = cursor1.fetchone()  # ziskanie id_dopravcu_spoje
                        cursor1.close()

                        cursor1 = connection.cursor()
                        cursor1.execute("SELECT meno, priezvisko FROM Dopravca WHERE id='%s';" % id_dopravca)
                        carrier_name = cursor1.fetchone()  # ziskanie id_dopravcu_spoje
                        cursor1.close()

                        # ziskanie poctu volnych dostupnych miest v danom spoji dan0ho vozidla
                        cursor1 = connection.cursor()
                        cursor1.execute("SELECT id_vozidla FROM Vozidlo_Spoj WHERE id_spoju='%s';" % row1[1])
                        id_vozidla = cursor1.fetchone()
                        cursor1.close()
                        cursor1 = connection.cursor()
                        cursor1.execute("SELECT pocet_miest FROM Vozidlo WHERE id='%s';" % id_vozidla)
                        availableSeats = cursor1.fetchone()
                        cursor1.close()

                        fromCityTime = row1[0]
                        toCityTime = row2[0]
                        connectionNumber = row1[1]  # cislo spoju
                        availableSeats = availableSeats[0]  # array to string
                        carrier_name = carrier_name[0] + carrier_name[1]  # spojenie meno a priezvisko do jedneho

                        tmp_secsTimeFromCity = tmp_secsTimeFromCity.rsplit(':',
                                                                           1)  # splitnutie na hodiny [0] a minuty [1]
                        tmp_secsTimeToCity = tmp_secsTimeToCity.rsplit(':', 1)  # splitnutie na hodiny [0] a minuty [1]

                        tmp_HoursSecsFromCity = int(tmp_secsTimeFromCity[0]) * 3600  # hodiny v sekudach
                        tmp_MinutesSecsFromCity = int(tmp_secsTimeFromCity[1]) * 60  # minuty v sekudach

                        tmp_HoursSecsToCity = int(tmp_secsTimeToCity[0]) * 3600  # hodiny v sekudach
                        tmp_MinutesSecsToCity = int(tmp_secsTimeToCity[1]) * 60  # minuty v sekudach
                        connectionTimeHours = ((tmp_HoursSecsToCity + tmp_MinutesSecsToCity) - (
                                tmp_HoursSecsFromCity + tmp_MinutesSecsFromCity)) / 3600  # dlzka trvania spoju v hodinach
                        connectionTimeMinutes = ((tmp_HoursSecsToCity + tmp_MinutesSecsToCity) - (
                                tmp_HoursSecsFromCity + tmp_MinutesSecsFromCity)) / 60  # dlzka trvania spoju v minutach
                        connectionTimeHours = float(connectionTimeHours)

                        # prevod hodin na hodiny a minuty
                        hours = connectionTimeHours
                        mins = (connectionTimeHours * 60) % 60
                        hours = int(hours)
                        hours = str(hours)
                        mins = int(mins)
                        mins = str(mins)
                        connectionTimeHours = hours + 'hod ' + mins + 'min'

                        cursor = connection.cursor()
                        cursor.execute("SELECT symbol from Symboly")
                        symbols = cursor.fetchall()
                        cursor.close()

                        # ziskanie konkretneho dna z datumu
                        tmp2_dateOfConnection = str(tmp_dateOfConnection)
                        tmp2_dateOfConnection = tmp2_dateOfConnection.rsplit('-',
                                                                             1)  # splitnutie na rok a mesiac [0] a den [1]
                        tmp_unsplittedYearAndMonth = str(tmp2_dateOfConnection[0])
                        tmp_yearAndMonth = tmp_unsplittedYearAndMonth.rsplit('-', 1)  # splitnutie na rok [0] mesiac [1]
                        ans = datetime.date(int(tmp_yearAndMonth[0]), int(tmp_yearAndMonth[1]),
                                            int(tmp2_dateOfConnection[1]))
                        dayOfConnection = ans.strftime("%A")
                        if dayOfConnection == 'Monday':
                            dayOfConnection = 'po'
                            if nextDay:
                                dayOfConnection = 'ut'
                        elif dayOfConnection == 'Tuesday':
                            dayOfConnection = 'ut'
                            if nextDay:
                                dayOfConnection = 'str'
                        elif dayOfConnection == 'Wednesday':
                            dayOfConnection = 'st'
                            if nextDay:
                                dayOfConnection = ''.join(symbols[0]) + 't'
                        elif dayOfConnection == 'Thursday':
                            dayOfConnection = ''.join(symbols[0]) + 't'
                            if nextDay:
                                dayOfConnection = 'pi'
                        elif dayOfConnection == 'Friday':
                            dayOfConnection = 'pi'
                            if nextDay:
                                dayOfConnection = 'so'
                        elif dayOfConnection == 'Saturday':
                            dayOfConnection = 'so'
                            if nextDay:
                                dayOfConnection = 'ne'
                        elif dayOfConnection == 'Sunday':
                            dayOfConnection = 'ne'
                            if nextDay:
                                dayOfConnection = 'po'

                        # ak uz prebieha hlavny for po 2.krat (druhy priebeh databazy - pre ostatne dni, nie len najblizsie spoje) tak sa zvysi datum o 1 vyssie
                        if nextDay:
                            tmp2_dateOfConnection[1] = int(tmp2_dateOfConnection[1])
                            tmp2_dateOfConnection[1] += x
                            tmp2_dateOfConnection[1] = str(tmp2_dateOfConnection[1])
                        # dokopy den, mesiac a konkretny den
                        dateAndDayOfConnection = tmp2_dateOfConnection[1] + '.' + tmp_yearAndMonth[
                            1] + '. ' + dayOfConnection

                        # vypocitanie ceny na zaklade doby trvania spoju v minutach a ceny za jednu minutu
                        int(connectionTimeMinutes)
                        priceOfConnection = connectionTimeMinutes * 0.08
                        priceOfConnection = str(round(priceOfConnection, 2))
                        priceOfConnection = priceOfConnection + ''.join(symbols[1])

                        # formatovanie casu
                        if tmp_timeFromCity < 959:
                            fromCityTime = ' ' + fromCityTime
                        if tmp_timeToCity < 959:
                            toCityTime = ' ' + toCityTime

                        # ziskanie vsetkych miest, cey ktore spoj prechadza pre informaciu pre cestujucich pri listku
                        cursor1 = connection.cursor()
                        cursor1.execute("SELECT id_zastavky FROM Spoj_Zastavka WHERE id_spoju='%s';" % connectionNumber)
                        tmp_idAllCitiesOfConnection = cursor1.fetchall()
                        cursor1.close()

                        # prevod vsetkych cisiel spojov do jedneho pola
                        idAllCitiesOfConnection = []
                        for i in range(len(tmp_idAllCitiesOfConnection)):
                            idAllCitiesOfConnection.append(tmp_idAllCitiesOfConnection[i][0])

                        allCitiesOfConnection = []
                        for i in idAllCitiesOfConnection:
                            # vyhladanie mesta pre dane id
                            cursor1 = connection.cursor()
                            cursor1.execute("SELECT nazov_zastavky FROM Zastavky WHERE id='%s';" % i)
                            cityNameConnection = cursor1.fetchone()
                            cursor1.close()

                            # vyhladanie casu prejazdu cez dane mesto
                            cursor2 = connection.cursor()
                            cursor2.execute(
                                "SELECT cas_prejazdu FROM Spoj_Zastavka WHERE id_zastavky='%s' and id_spoju='%s';" % (
                                i, connectionNumber))
                            timeOfDeparture = cursor2.fetchone()
                            cursor2.close()

                            timeOfDeparture = timeOfDeparture[0].replace(":", "")  # odstranenie ':' pre prevod na int
                            timeOfDeparture = int(timeOfDeparture)  # string to int pre porovanie casov
                            if tmp_timeFromCity <= timeOfDeparture:
                                modifiedTimeOfDeparture = str(timeOfDeparture)
                                modifiedTimeOfDeparture = list(modifiedTimeOfDeparture)
                                modifiedTimeOfDeparture.insert(-2, ':')
                                tmp_str = ""
                                modifiedTimeOfDeparture = tmp_str.join(modifiedTimeOfDeparture)
                                allCitiesOfConnection.append(
                                    [cityNameConnection[0], timeOfDeparture, modifiedTimeOfDeparture])

                        # sortovanie casov od najvacsieho po najmensi - ale ako medzispoje sa na stranke zobrazuju od najmensieho po najvacsie
                        allCitiesOfConnection.sort(key=lambda y: y[1], reverse=True)

                        allCitiesOfConnection = allCitiesOfConnection[
                                                1:-1]  # posielanie len medzizastavok - vymazanie prveho a posledneho prvku - zaciatok cesty a ciel

                        # zaverecne appendovanie dat do zoznamov
                        if tmp_timeFromCity > timeFromDate and not nextDay and counterOfConnections < 5:  # porovnanie casu odchodu a zvoleneho casu uzivatelom pre najblizsie spoje
                            possibleBusConnections.append(
                                [connectionNumber, fromCity, fromCityTime, toCity, toCityTime, carrier_name,
                                 availableSeats, dateAndDayOfConnection, connectionTimeHours, priceOfConnection,
                                 allCitiesOfConnection])
                            counterOfConnections += 1
                        if nextDay and counterOfConnections < 5:  # pre dalsie spoje, na dalsi den - rovnake spoje, len datum o cislo vyssi a od zaciatku dna 00:00 vsetky, nie len najblizsie v dany den
                            laterPossibleBusConnections.append(
                                [connectionNumber, fromCity, fromCityTime, toCity, toCityTime, carrier_name,
                                 availableSeats, dateAndDayOfConnection, connectionTimeHours, priceOfConnection,
                                 allCitiesOfConnection])
                            counterOfConnections += 1

    possibleBusConnections = possibleBusConnections + laterPossibleBusConnections  # spojenie najblizsich vyhovujucich spojov a spojov pre dalsi den napr
    print(possibleBusConnections)
    if boolLoadMore != 'connections':
        return possibleBusConnections
    # possibleBusConnections - vo formate: cislo_spoju, fromCity, cas_prejazdu(fromCity), toCity, cas_prejazdu(toCity), dopravca, pocet volnych miest, datum spoju, doba trvania spoju

    return render_template('connections.html', data=possibleBusConnections)


@app.route('/loadMore/<x>')
def loadMore(x):
    boolLoadMore = True
    nextConnections = search(boolLoadMore, x)
    nextConnections = json.dumps(nextConnections)
    # return {"data": nextConnections}
    return nextConnections


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
            loginData = {'message': 'login', 'email': user_email, 'name': meno, 'status': 'cestujuci'}
            return index()
    for (meno, email, heslo) in administrator:
        if email == user_email and heslo == password:
            administrator.close()
            loginData = {'message': 'login', 'email': user_email, 'name': meno, 'status': 'administrator'}
            return index()
    for (meno, email, heslo) in personal:
        if email == user_email and heslo == password:
            personal.close()
            loginData = {'message': 'login', 'email': user_email, 'name': meno, 'status': 'personal'}
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
    cursor.execute("insert into `Cestujuci` (meno, priezvisko, email, heslo) VALUES (%s, %s, %s, %s)",
                   (fname, lname, user_email, password))
    connection.commit()
    cursor.close()

    loginData = {'message': 'login', 'email': user_email, 'name': fname, 'status': 'cestujuci'}
    return index()


# DOPRAVCA
@app.route('/carrier/addVehicle/<carrier_name>', methods=['GET', 'POST'])
def addVehicle(carrier_name):
    # prihlaseny bude Dopravca - Martin mi bude musiet poslat nazov dopravcu, akym nazvom je prihlaseny
    # podla nazvu Dopravcu si vyhladam jeho id v DB
    # Dopravca si chce pridat nove vozidlo
    # bude tam policko pre pocet_miest, popis_vozidla(max 1000 znakov), v DB este info o ID Dopravcu - to doplnim ja
    # Martin mi posle z formularov data v tvare:

    carrierName = carrier_name
    numberOfSeats = request.form['numberOfSeats']
    descriptionOfBus = request.form['descriptionOfBus']
    actualLocation = ' '

    # TODO v db zmenit v Dopravca: meno a priezvisko len na nazov a zmenit to aj vo funkcii search
    # vyhladam nazov dopravcu v DB a zistim tak id dopravcu
    cursor1 = connection.cursor()
    cursor1.execute("SELECT id FROM Dopravca WHERE nazov='%s';" % carrierName)
    idOfCarrier = cursor1.fetchone()
    cursor1.close()
    idOfCarrier = idOfCarrier[0]  # ziskanie z listu len prvy prvok - integer (id dopravcu)

    print(idOfCarrier)
    print(carrierName)
    print(numberOfSeats)
    print(descriptionOfBus)

    # pridanie vozidla do DB
    cursor1 = connection.cursor()
    cursor1.execute(
        "insert into `Vozidlo` (pocet_miest, popis_vozidla, aktualna_poloha, id_dopravca_vozidlo) VALUES (%s, %s, %s, %s)",
        (numberOfSeats, descriptionOfBus, actualLocation, idOfCarrier))
    connection.commit()
    cursor1.close()


# DOPRAVCA
@app.route('/carrier/addPersonal/<carrier_name>', methods=['GET', 'POST'])
def addPersonal(carrier_name):
    # popis fce: pridanie personalu do DB pre daneho dopravcu

    carrierName = carrier_name
    fname = request.form['fname']
    lname = request.form['lname']
    user_email = request.form['email']
    password = request.form['password']

    # vyhladam nazov dopravcu v DB a zistim tak id dopravcu
    cursor1 = connection.cursor()
    cursor1.execute("SELECT id FROM Dopravca WHERE nazov='%s';" % carrierName)
    idOfCarrier = cursor1.fetchone()
    cursor1.close()
    idOfCarrier = idOfCarrier[0]  # ziskanie z listu len prvy prvok - integer (id dopravcu)

    print(idOfCarrier)
    print(carrierName)
    print(fname)
    print(lname)
    print(user_email)
    print(password)

    # pridanie personalu do DB pre daneho dopravcu
    cursor1 = connection.cursor()
    cursor1.execute(
        "insert into `Personal` (meno, priezvisko, email, heslo, id_dopravca_personal) VALUES (%s, %s, %s, %s)",
        (fname, lname, user_email, password, idOfCarrier))
    connection.commit()
    cursor1.close()

    # TODO EDIT A MAZANIE UZIVALELSKYCH UCTOV PERSONALU DANEHO DOPRAVCU
    # https://swcarpentry.github.io/sql-novice-survey/09-create/index.html


# DOPRAVCA
@app.route('/carrier/showMyVehicles/<carrier_name>', methods=['GET', 'POST'])
def showMyVehicles(carrier_name):
    # popis fce: zobrazenie vsetkych autobusov daneho dopravcu

    carrierName = carrier_name

    # vyhladam nazov dopravcu v DB a zistim tak id dopravcu
    cursor1 = connection.cursor()
    cursor1.execute("SELECT id FROM Dopravca WHERE nazov='%s';" % carrierName)
    idOfCarrier = cursor1.fetchone()
    cursor1.close()
    idOfCarrier = idOfCarrier[0]  # ziskanie z listu len prvy prvok - integer (id dopravcu)

    print(idOfCarrier)

    # ziskanie vsetkych vozidiel, pre edit a mazanie dopravcom
    cursor1 = connection.cursor()
    cursor1.execute(
        "SELECT id, pocet_miest, popis_vozidla, aktualna_poloha FROM Vozidlo WHERE id_dopravca_vozidlo='%s';" % idOfCarrier)
    allVehicles = cursor1.fetchall()
    cursor1.close()

    print(allVehicles)

    # TODO EDITOVANIE A MAZANIE VOZIDIEL Z DB
    # https://swcarpentry.github.io/sql-novice-survey/09-create/index.html


# ADMIN
@app.route('/admin/editUsers/', methods=['GET', 'POST'])
def editUsers():
    # popis fce: zobrazenie vsetkych uzivatelskych uctov cestujucich

    # zobrazenie vsetkych uctov
    cursor1 = connection.cursor()
    cursor1.execute("SELECT meno, priezvisko, email, heslo FROM Cestujuci")
    allUsers = cursor1.fetchall()
    cursor1.close()

    print(allUsers)

    # TODO EDIT UZIVATELSKYCH INFO A PREPISANIE NOVYCH INFO DO DATABAZY

# kontrola pri nakupe listka ci uzivatel klikol na registrovat alebo prihlasit
@app.route('/validate/<regOrSignIn>', methods=['GET', 'POST'])
def validate(regOrSignIn):
    global loginData
    user_email = request.form['email']
    print(user_email)
    if regOrSignIn == 'signIn':
        password = request.form['password']
        print(password)
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
                loginData = {'message': 'success'}
                loginData = json.dumps(loginData)
                return loginData
        for (meno, email, heslo) in administrator:
            if email == user_email and heslo == password:
                administrator.close()
                loginData = {'message': 'success'}
                loginData = json.dumps(loginData)
                return loginData
        for (meno, email, heslo) in personal:
            if email == user_email and heslo == password:
                personal.close()
                loginData = {'message': 'success'}
                loginData = json.dumps(loginData)
                return loginData
        cestujuci.close()
        administrator.close()
        personal.close()
        data = {'message': 'log'}
        data = json.dumps(data)
        return data

    if regOrSignIn == 'register':
        fname = request.form['fname']
        lname = request.form['lname']
        password = request.form['password']

        cursor = connection.cursor()
        cursor.execute("SELECT email FROM Cestujuci")
        for (email) in cursor:
            email = ''.join(email)
            if email == user_email:
                cursor.close()
                data = {'message': 'reg'}
                data = json.dumps(data)
                return data
        cursor.close()

        cursor = connection.cursor()
        cursor.execute("insert into `Cestujuci` (meno, priezvisko, email, heslo) VALUES (%s, %s, %s, %s)",
                       (fname, lname, user_email, password))
        connection.commit()
        cursor.close()

        loginData = {'message': 'success'}
        loginData = json.dumps(loginData)
        return loginData


# nakup listkana konkretny spoj
@app.route('/purchase/<signedInOrOneTime>', methods=['GET', 'POST'])
def purchase(signedInOrOneTime):
    global loginData
    signedIn = False
    oneTime = False

    # ziskanie spoju, na ktory vytvorim jizdenku
    data = request.form['data']
    numberOfTickets = request.form['number']  # pocet listkov
    print(data)
    print(numberOfTickets)

    user_email = request.form['email']
    print(user_email)

    # data parsing
    numberOfConnection = data[0]
    fromCity = data[1]
    timeFromCity = data[2]
    toCity = data[3]
    timeToCity = data[4]
    carrier_name = data[5]
    date = data[7]
    price = data[9]




    # signedIn
    if signedInOrOneTime == 'signedIn':
        signedIn = True

    # oneTime
    if signedInOrOneTime == 'oneTime':
        oneTime = True

    # vytvorenie jizdenky

    # odcitanie poctu miest z daneho spoju


class databaseCheck(threading.Thread):
    def run(self, *args, **kwargs):
        while True:
            try:
                pymysql.connect(host='92.52.58.251', user='admin', password='password', db='iis')
            except pymysql.Error as error:
                webhookUrl = 'https://maker.ifttt.com/trigger/error/with/key/jglncn-jhDn3EyEKlB3nkuB2VDNC8Rs4Fuxg5IpNE4'
                requests.post(webhookUrl, headers={'Content-Type': 'application/json'})
                print("Cannot connect to database. Error: " + error)
            time.sleep(1800)


if __name__ == '__main__':
    databaseCheck = databaseCheck()
    databaseCheck.start()
    app.run(debug=True)
