from flask import Flask, render_template, request
from fpdf import FPDF  # fpdf class
import os
import time
import json
import qrcode
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
generatePDFdata = [] # data z purchase pre signIn, signedIn a register uzivatelov (okrem oneTime)

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


@app.route('/profile')
def profile():
    return render_template("profile.html")


@app.route('/tickets')
def tickets():
    # TODO budem vracat vsetky uzivatelove listky
    # na listku bude teda cislo toho listku, datum, pocet miest, odkial kam, casy
    print(generatePDFdata)
    user_email = request.form['email']

    # ziskanie id cestujuceho
    cursor1 = connection.cursor()
    cursor1.execute("SELECT id FROM Cestujuci WHERE email='%s';" % user_email)
    idOfUser = cursor1.fetchone()
    cursor1.close()
    idOfUser = idOfUser[0]
    print(idOfUser)

    # ziskanie id jizdeniek
    cursor1 = connection.cursor()
    cursor1.execute(
        "SELECT id FROM Jizdenka WHERE id_cestujuci_jizdenka='%s';" % idOfUser)
    idOfTickets = cursor1.fetchall()
    cursor1.close()

    ids = []
    for i in idOfTickets:
        for j in i:
            ids.append(''.join(str(j)))


    fname = generatePDFdata[0][0]
    lname = generatePDFdata[0][1]
    numberOfConnection = generatePDFdata[0][2]
    date = generatePDFdata[0][3]
    numberOfTickets = generatePDFdata[0][4]
    fromCity = generatePDFdata[0][5]
    timeFrom = generatePDFdata[0][6]
    toCity = generatePDFdata[0][7]
    timeTo = generatePDFdata[0][8]
    carrier_name = generatePDFdata[0][9]
    user_email = generatePDFdata[0][10]
    idOfTicket = generatePDFdata[0][11][0]
    idOfTicket = str(idOfTicket)

    # Generovanie PDF
    generatePDF(fname, lname, numberOfConnection, date, numberOfTickets, fromCity, timeFrom, toCity, timeTo,
                carrier_name, user_email, idOfTicket)
    data = user_email
    data = {'email': user_email, 'ids': ids}
    return render_template("tickets.html", data=data)


@app.route('/personal')
def personal():
    return render_template("personal.html")


@app.route('/carrier')
def carrier():
    return render_template("carrier.html")


@app.route('/administrator')
def administrator():
    return render_template("administrator.html")


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
            for row2 in possibilities_toCity:
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
                        cursor1.execute("SELECT nazov FROM Dopravca WHERE id='%s';" % id_dopravca)
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
                            if tmp_timeFromCity <= timeOfDeparture and tmp_timeToCity >= timeOfDeparture:
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
                        if tmp_timeFromCity > timeFromDate and not nextDay:  # porovnanie casu odchodu a zvoleneho casu uzivatelom pre najblizsie spoje
                            possibleBusConnections.append(
                                [connectionNumber, fromCity, fromCityTime, toCity, toCityTime, carrier_name,
                                 availableSeats, dateAndDayOfConnection, connectionTimeHours, priceOfConnection,
                                 allCitiesOfConnection, tmp_timeFromCity])
                            counterOfConnections += 1
                            possibleBusConnections.sort(key=lambda y: y[
                                11])  # sortovanie, aby boli spoje zoradene od najmensieho cisla po najvacsie pre zobrazenie
                        if nextDay:  # pre dalsie spoje, na dalsi den - rovnake spoje, len datum o cislo vyssi a od zaciatku dna 00:00 vsetky, nie len najblizsie v dany den
                            laterPossibleBusConnections.append(
                                [connectionNumber, fromCity, fromCityTime, toCity, toCityTime, carrier_name,
                                 availableSeats, dateAndDayOfConnection, connectionTimeHours, priceOfConnection,
                                 allCitiesOfConnection, tmp_timeFromCity])
                            counterOfConnections += 1
                            laterPossibleBusConnections.sort(key=lambda y: y[
                                11])  # sortovanie, aby boli spoje zoradene od najmensieho cisla po najvacsie pre zobrazenie

    possibleBusConnections = possibleBusConnections + laterPossibleBusConnections  # spojenie najblizsich vyhovujucich spojov a spojov pre dalsi den napr

    # aby zoznam vratil len prvych 5 prkov vyhovujucich spojov
    if counterOfConnections >= 5:
        possibleBusConnections = possibleBusConnections[:5]
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
    if regOrSignIn == 'signIn':
        password = request.form['password']
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
                loginData = 'cestujuci+' + meno
                # loginData = json.dumps(loginData)
                return loginData
        for (meno, email, heslo) in administrator:
            if email == user_email and heslo == password:
                administrator.close()
                loginData = 'administrator+' + meno
                # loginData = json.dumps(loginData)
                return loginData
        for (meno, email, heslo) in personal:
            if email == user_email and heslo == password:
                personal.close()
                loginData = 'personal+' + meno
                # loginData = json.dumps(loginData)
                return loginData
        cestujuci.close()
        administrator.close()
        personal.close()
        data = 'log'
        # data = json.dumps(data)
        return data

    if regOrSignIn == 'register':
        cursor = connection.cursor()
        cursor.execute("SELECT email FROM Cestujuci")
        for (email) in cursor:
            email = ''.join(email)
            if email == user_email:
                cursor.close()
                data = 'reg'
                # data = json.dumps(data)
                return data
        cursor.close()

        loginData = 'success'
        # loginData = json.dumps(loginData)
        return loginData


# nakup listkana konkretny spoj
@app.route('/purchase/<signedInOrOneTime>', methods=['GET', 'POST'])
def purchase(signedInOrOneTime):
    global loginData, lname, fname

    # ziskanie spoju, na ktory vytvorim jizdenku
    tmp_data = request.form['data']
    data = list(tmp_data.split(","))
    numberOfTickets = request.form['number']  # pocet listkov

    user_email = request.form['email']

    # jednorazovy nakup
    if signedInOrOneTime == 'oneTime':
        fname = request.form['fname']
        lname = request.form['lname']
        password = ' '  # registracia bez hesla, pretoze je to jednorazovy nakup
        cursor = connection.cursor()
        cursor.execute("insert into `Cestujuci` (meno, priezvisko, email, heslo) VALUES (%s, %s, %s, %s)",
                       (fname, lname, user_email, password))
        connection.commit()
        cursor.close()

    # registrovat
    if signedInOrOneTime == 'register':
        fname = request.form['fname']
        lname = request.form['lname']
        password = request.form['password']

        cursor = connection.cursor()
        cursor.execute("insert into `Cestujuci` (meno, priezvisko, email, heslo) VALUES (%s, %s, %s, %s)",
                       (fname, lname, user_email, password))
        connection.commit()
        cursor.close()

    cities = []  # zoznam pre ulozenie miest, odkial kam ide spoj jizdenky a nasledne to sluzi pre ziskanie id danych miest
    # data parsing
    numberOfConnection = data[0]
    cities.append(data[1])
    timeFromCity = data[2]
    cities.append(data[3])
    timeToCity = data[4]
    carrier_name = data[5]
    date = data[7]
    price = data[9]

    # ziskanie id cestujuceho
    if signedInOrOneTime != 'oneTime':  # lebo jednorazovy by mohol mat rovnaky email a po druhykrat by sa vybral ten prvy kupeny listok
        cursor1 = connection.cursor()
        cursor1.execute("SELECT id, meno, priezvisko FROM Cestujuci WHERE email='%s';" % user_email)
        idOfUser = cursor1.fetchone()
        cursor1.close()
        tmp_fname_lname = idOfUser
        idOfUser = idOfUser[0]
        if signedInOrOneTime == 'signIn' or signedInOrOneTime == 'signedIn':
            fname = tmp_fname_lname[1]
            lname = tmp_fname_lname[2]

    if signedInOrOneTime == 'oneTime':
        cursor1 = connection.cursor()
        cursor1.execute("SELECT id FROM Cestujuci WHERE email='%s';" % user_email)
        idOfUser = cursor1.fetchall()
        cursor1.close()
        idOfUser = idOfUser[-1][
            0]  # ziskanie posledneho vytvoreneho id (keby jednorazovy uzivatel uz druhykrat kupoval listok)

    # ziskanie id personalu daneho spoju
    cursor1 = connection.cursor()
    cursor1.execute("SELECT id_personalu FROM Personal_Spoj WHERE id_spoju='%s';" % numberOfConnection)
    idOfPersonal = cursor1.fetchone()
    cursor1.close()
    idOfPersonal = idOfPersonal[0]

    # vytvorenie jizdenky
    cursor1 = connection.cursor()
    cursor1.execute(
        "insert into `Jizdenka` (pocet_miest, datum, id_spoj_jizdenky, id_cestujuci_jizdenka, id_personal_jizdenka) VALUES (%s, %s, %s, %s, %s)",
        (numberOfTickets, date, numberOfConnection, idOfUser, idOfPersonal))
    connection.commit()
    cursor1.close()

    # ziskanie id novo vytvorenej jizdenky
    cursor1 = connection.cursor()
    cursor1.execute(
        "SELECT id FROM Jizdenka WHERE datum='%s' and id_spoj_jizdenky='%s' and id_cestujuci_jizdenka='%s';" % (
            date, numberOfConnection, idOfUser))
    idOfTicket = cursor1.fetchall()
    cursor1.close()
    idOfTicket = idOfTicket[-1]  # ziskanie posledneho vytvoreneho id (teda listku) konkretneho uzivatela

    # ziskanie id zastavok pre vlozenie do tabulky Jizdenka-Zastavky - pre kt. mesta je vystavena jizdenka
    for i in range(2):
        cursor1 = connection.cursor()
        cursor1.execute("SELECT id FROM Zastavky WHERE nazov_zastavky='%s';" % cities[i])
        idOfCity = cursor1.fetchone()
        cursor1.close()
        idOfCity = idOfCity[0]

        cursor1 = connection.cursor()
        cursor1.execute(
            "insert into `Jizdenka_Zastavky` (id_jizdenka, id_zastavka) VALUES (%s, %s)", (idOfTicket, idOfCity))
        connection.commit()
        cursor1.close()

    # TODO odcitanie poctu miest z daneho spoju

    if signedInOrOneTime == 'register' or signedInOrOneTime == 'signIn' or signedInOrOneTime == 'signedIn':
        generatePDFdata.append([fname, lname, numberOfConnection, date, numberOfTickets, cities[0], timeFromCity, cities[1], timeToCity, carrier_name, user_email, idOfTicket])
        return tickets()
    if signedInOrOneTime == 'oneTime':
        data = []
        idOfTicket = str(idOfTicket[0])
        data.append([user_email, idOfTicket])
        generatePDF(fname, lname, numberOfConnection, date, numberOfTickets, cities[0], timeFromCity, cities[1],
                    timeToCity,
                    carrier_name, user_email, idOfTicket)

        return render_template('ticket.html', data=data)


def generatePDF(fname, lname, numberOfConnection, date, numberOfTickets, fromCity, timeFrom, toCity, timeTo,
                carrier_name, user_email, idOfTicket):
    cursor = connection.cursor()
    cursor.execute("SELECT symbol from Symboly")
    symbols = cursor.fetchall()
    cursor.close()

    # GENEROVANIE PDF

    class PDF(FPDF):
        pass

    name = fname + ' ' + lname
    timeFromTo = timeFrom + ' ' + date + '  ' + timeTo + ' ' + date
    numberOfConnection = numberOfConnection + '  ' + carrier_name
    numberOfTickets = 'Miest: ' + numberOfTickets

    data = name + "; " + numberOfConnection + "; " + fromCity + "; " + toCity + "; " + timeFromTo + "; " + numberOfTickets
    qr = qrcode.QRCode(version=None, box_size=10, border=0)
    qr.add_data(data)
    qr.make(fit=True)
    img = qr.make_image(fill='black', back_color='white')
    img.save(os.path.dirname(
        os.path.realpath(__file__)) + '/static/qr/' + user_email + '_' + idOfTicket + '.png')

    pdf = PDF(orientation='L', format='A5')
    pdf.add_font("OpenSans", "", os.path.dirname(os.path.realpath(__file__)) + '/static/OpenSans.ttf', uni=True)
    pdf.add_page()
    pdf.set_line_width(0.0)
    pdf.set_font('Times', 'B', size=17)
    pdf.cell(0, 0, txt="CP ", ln=1, align="L")
    pdf.cell(8)
    pdf.set_font('Times', 'I', size=10)
    pdf.cell(0, 2, txt="by (j)Elita", ln=1)
    pdf.ln(12)
    pdf.cell(4)
    pdf.cell(183, 40, ' ', 'LTRB', 0, 'L', 0)
    pdf.ln(0)
    pdf.cell(4)
    pdf.cell(183, 20, ' ', 'B', 0, 'L', 0)  # middle horizontal line
    pdf.ln(0)
    pdf.cell(61)
    pdf.cell(1, 40, ' ', 'L', 0, 'L', 0)  # first vertical line
    pdf.ln(0)
    pdf.cell(122)
    pdf.cell(1, 40, ' ', 'L', 0, 'L', 0)  # second vertical line
    pdf.ln(10)
    pdf.cell(4)
    pdf.cell(183, 20, ' ', 'B', 0, 'L', 0)  # middle horizontal line
    pdf.ln(-20)
    pdf.cell(61)
    pdf.cell(125.8, 20, ' ', 'B', 0, 'L', 0)  # middle horizontal line
    pdf.ln(20)
    pdf.cell(14)
    str_ticket = symbols[2][0]
    pdf.set_font('OpenSans', size=16)
    pdf.cell(0, 2, txt=str_ticket, ln=1)
    pdf.ln(-8)
    pdf.cell(85)
    str_connection = 'Spoj'
    str_name = 'Meno'
    pdf.set_font('Times', 'B', size=13)
    pdf.cell(0, 2, txt=str_connection, ln=1)
    pdf.ln(-2)
    pdf.cell(148)
    pdf.cell(0, 2, txt=str_name, ln=1)
    pdf.ln(18)
    pdf.cell(30)
    str_from = 'Z'
    pdf.cell(0, 2, txt=str_from, ln=1)
    pdf.ln(-2)
    pdf.cell(73)
    pdf.set_font('OpenSans', size=13)
    str_time = 'Odchod - ' + symbols[3][0]
    pdf.cell(0, 2, txt=str_time, ln=1)
    pdf.ln(-12)
    pdf.cell(80)
    pdf.set_font('OpenSans', size=13)
    pdf.cell(0, 2, txt=numberOfConnection, ln=1)
    pdf.ln(8)
    pdf.cell(150)
    pdf.set_font('Times', 'B', size=13)
    str_to = 'DO'
    pdf.cell(0, 2, txt=str_to, ln=1)
    pdf.ln(8)
    pdf.cell(63)
    pdf.set_font('OpenSans', size=10)
    pdf.cell(0, 2, txt=timeFromTo, ln=1)  # datumy casy
    pdf.ln(-2)
    pdf.cell(129)
    pdf.set_font('OpenSans', size=12)
    pdf.cell(0, 2, txt=toCity, ln=1)  # kam
    pdf.ln(-2)
    pdf.cell(10)
    pdf.set_font('OpenSans', size=12)
    pdf.cell(0, 2, txt=fromCity, ln=1)  # odkial
    pdf.ln(-22)
    pdf.cell(138)
    pdf.set_font('OpenSans', size=12)
    pdf.cell(0, 2, txt=name, ln=1)  # meno
    pdf.ln(0)
    pdf.cell(25)
    pdf.set_font('OpenSans', size=10)
    pdf.cell(0, 2, txt=numberOfTickets, ln=1)  # pocet miest
    pdf.ln(30)
    pdf.cell(64)
    pdf.image(name=os.path.dirname(
        os.path.realpath(__file__)) + '/static/qr/' + user_email + '_' + idOfTicket + '.png', w=55)


    savePDFname = os.path.dirname(
        os.path.realpath(__file__)) + '/static/tickets/' + user_email + '_' + idOfTicket + '.pdf'
    print(savePDFname)
    pdf.output(savePDFname, 'F')
    return


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
