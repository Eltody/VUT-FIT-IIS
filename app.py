from apscheduler.schedulers.background import BackgroundScheduler
from flask import Flask, render_template, request, redirect, url_for
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
profileNameMainPage = ''


#############################################
@app.route('/')
def index():
    global profileNameMainPage
    global loginData
    cursor = connection.cursor()
    cursor.execute("SELECT nazov_zastavky from Zastavky")
    tmp = cursor.fetchall()
    cursor.close()
    cities = []
    for i in tmp:
        cities.append(''.join(i))
    if isinstance(loginData, str):
        loginData = {'message': ''}
    data = loginData.copy()
    loginData.clear()
    return render_template("index.html", cities=cities, data=data, name=profileNameMainPage)


@app.route('/profile')
def profile():
    return render_template("profile.html")


@app.route('/tickets', methods=['GET', 'POST'])
def tickets():
    user_email = request.form['email']

    # ziskanie id cestujuceho
    cursor1 = connection.cursor()
    cursor1.execute("SELECT id FROM Cestujuci WHERE email='%s';" % user_email)
    idOfUser = cursor1.fetchall()
    cursor1.close()

    allIdsOfUsers = []
    for i in idOfUser:
        for j in i:
            allIdsOfUsers.append(int(''.join(str(j))))

    allIdsOfTickets = []
    tmp_data = []
    for i in allIdsOfUsers:
        # ziskanie id jizdeniek
        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT id FROM Jizdenka WHERE id_cestujuci_jizdenka='%s';" % i)
        idsOfTickets = cursor1.fetchall()
        cursor1.close()

        tmp_allIdsOfTickets = []
        for m in idsOfTickets:
            for n in m:
                tmp_allIdsOfTickets.append(''.join(str(n)))
        allIdsOfTickets.append([tmp_allIdsOfTickets])

        # ziskanie id spojov
        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT id_spoj_jizdenky FROM Jizdenka WHERE id_cestujuci_jizdenka='%s';" % i)
        IdsOfConnections = cursor1.fetchall()
        cursor1.close()

        allIdsOfConnections = []
        for m in IdsOfConnections:
            for n in m:
                allIdsOfConnections.append(''.join(str(n)))

        idsOfVehicles = []
        for e in allIdsOfConnections:
            cursor1 = connection.cursor()
            cursor1.execute(
                "SELECT id_vozidla FROM Vozidlo_Spoj WHERE id_spoju='%s';" % e)
            tmp_idsOfVehicles = cursor1.fetchone()
            tmp_idsOfVehicles = tmp_idsOfVehicles[0]
            idsOfVehicles.append([tmp_idsOfVehicles])
            cursor1.close()

        allIdsOfVehicles = []
        for f in idsOfVehicles:
            for g in f:
                allIdsOfVehicles.append(''.join(str(g)))

        currentLocations = []
        for h in allIdsOfVehicles:
            cursor1 = connection.cursor()
            cursor1.execute(
                "SELECT aktualna_poloha FROM Vozidlo WHERE id='%s';" % h)
            tmp_currectLocations = cursor1.fetchone()
            tmp_currectLocations = tmp_currectLocations[0]
            currentLocations.append([tmp_currectLocations])
            cursor1.close()

        allCurrentLocations = []
        for k in currentLocations:
            for l in k:
                allCurrentLocations.append(''.join(str(l)))

        for y in range(len(allCurrentLocations)):
            currentLocation = allCurrentLocations[y]
            currentId = tmp_allIdsOfTickets[y]
            tmp_data.append([currentLocation, currentId])

    data = {'email': user_email, 'ids': tmp_data}
    return render_template("tickets.html", data=data)


@app.route('/personal', methods=['GET', 'POST'])
def personal():
    emailPersonal = request.form['email']

    cursor = connection.cursor()
    cursor.execute("SELECT symbol from Symboly")
    symbols = cursor.fetchall()
    cursor.close()

    # ziskanie id personalu z emailu
    cursor = connection.cursor()
    cursor.execute("SELECT id FROM Personal WHERE email='%s';" % emailPersonal)
    idPersonal = cursor.fetchone()
    cursor.close()
    idPersonal = idPersonal[0]

    # ziskanie ids spojov, na ktorych dany personal pracuje
    cursor1 = connection.cursor()
    cursor1.execute(
        "SELECT id_spoju FROM Personal_Spoj WHERE id_personalu='%s';" % idPersonal)
    tmp = cursor1.fetchall()
    cursor1.close()

    idsOfAllConnections = []
    for m in tmp:
        for n in m:
            idsOfAllConnections.append(''.join(str(n)))

    vehicles = []
    allIdsAndTimesOfConnection = []
    sameVehicle = []
    print(idsOfAllConnections)
    for i in idsOfAllConnections:
        allTimesSplitted = []
        tmp_fromAndToTime = []
        cities = []

        # ziskanie ids z konkretneho spoju
        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT id_vozidla FROM Vozidlo_Spoj WHERE id_spoju='%s';" % i)
        idOfVehicle = cursor1.fetchone()
        cursor1.close()
        if idOfVehicle is None:
            continue
        idOfVehicle = idOfVehicle[0]
        if idOfVehicle in sameVehicle:
            continue
        sameVehicle.append(idOfVehicle)

        # ziskanie vsetkych casov, cez ktore spoj premava
        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT cas_prejazdu FROM Spoj_Zastavka WHERE id_spoju='%s';" % i)
        tmp_allTimes = cursor1.fetchall()
        cursor1.close()

        allTimes = []
        for m in tmp_allTimes:
            for n in m:
                allTimes.append(''.join(str(n)))

        # odstranenie ':' z casu
        for k in range(len(allTimes)):
            tmp2 = allTimes[k].replace(":", "")  # odstranenie ':' pre prevod na int
            tmp2 = int(tmp2)
            allTimesSplitted.append(tmp2)

        # sortovanie, aby boli spoje zoradene od najmensieho cisla po najvacsie pre zobrazenie
        allTimesSplitted.sort()
        timesWithColon = []
        for timeS in allTimesSplitted:
            if timeS > 959:
                timeS = str(timeS)
                tmp_time = timeS[:2] + ':' + timeS[2:]
                timesWithColon.append(tmp_time)
            elif timeS <= 959:
                timeS = str(timeS)
                tmp_time = timeS[:1] + ':' + timeS[1:]
                timesWithColon.append(tmp_time)
        fromTime = str(timesWithColon[0])
        toTime = str(timesWithColon[-1])

        fromTime = str(fromTime)
        toTime = str(toTime)

        tmp_fromAndToTime.append(fromTime)
        tmp_fromAndToTime.append(toTime)

        for t in timesWithColon:
            cursor1 = connection.cursor()
            cursor1.execute("SELECT id_zastavky FROM Spoj_Zastavka WHERE id_spoju='%s' and cas_prejazdu='%s';" % (
                i, t))
            idOfStop = cursor1.fetchone()
            cursor1.close()
            idOfStop = idOfStop[0]

            cursor1 = connection.cursor()
            cursor1.execute(
                "SELECT nazov_zastavky FROM Zastavky WHERE id='%s';" % idOfStop)
            city = cursor1.fetchone()
            cursor1.close()
            cities.append(city[0])

        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT aktualna_poloha FROM Vozidlo WHERE id='%s';" % idOfVehicle)
        currentStop = cursor1.fetchone()
        cursor1.close()
        currentStop = currentStop[0]

        vehicle = str(idOfVehicle) + ' | ' + cities[0] + ' ' + symbols[5][0] + ' ' + cities[-1]
        vehicles.append([vehicle, cities, currentStop])

    # tickets = [[id, email],[id, email]]
    # ziskanie vsetkych id jizdeniek, ktore patria pod dany personal - spoje, cez ktore personal pracuje
    allTickets = []
    cursor1 = connection.cursor()
    cursor1.execute("SELECT id FROM Jizdenka WHERE id_personal_jizdenka='%s';" % idPersonal)
    tmp_idsOfTickets = cursor1.fetchall()
    cursor1.close()

    allIdsTickets = []
    for m in tmp_idsOfTickets:
        for n in m:
            allIdsTickets.append(''.join(str(n)))

    for i in allIdsTickets:
        # ziskanie id cestujuceho z jizdenky a nasledne zistenie jeho emailu
        cursor1 = connection.cursor()
        cursor1.execute("SELECT id_cestujuci_jizdenka FROM Jizdenka WHERE id='%s';" % i)
        idPassenger = cursor1.fetchone()
        cursor1.close()
        idPassenger = idPassenger[0]

        cursor1 = connection.cursor()
        cursor1.execute("SELECT email FROM Cestujuci WHERE id='%s';" % idPassenger)
        emailPassenger = cursor1.fetchone()
        cursor1.close()
        emailPassenger = emailPassenger[0]
        dataToSend = str(i) + ' | ' + emailPassenger
        allTickets.append(dataToSend)

    data = {'tickets': allTickets, 'vehicles': vehicles}

    # vypis vsetkych miest pre novy ticket ktory vytvara personal
    cursor = connection.cursor()
    cursor.execute("SELECT nazov_zastavky from Zastavky")
    tmp = cursor.fetchall()
    cursor.close()
    cities = []
    for i in tmp:
        cities.append(''.join(i))
    print(cities)

    return render_template("personal.html", cities=cities, data=data)


# aktualizovanie polohy personalom, ktory sa nachadza v danom spoji
@app.route('/updatePosition', methods=['GET', 'POST'])
def updatePosition():
    idOfVehicle = request.form['vehicle']
    updateTo = request.form['stop']

    idOfVehicle = idOfVehicle.split(' ', 1)
    idOfVehicle = idOfVehicle[0]

    # aktualizacia polohy vozidla podla jeho id
    cursor1 = connection.cursor()
    cursor1.execute("UPDATE Vozidlo SET aktualna_poloha = '%s' WHERE id = '%s'" % (updateTo, idOfVehicle))
    connection.commit()
    cursor1.close()

    return ""


# funkcia pre vymazanie listku z DB, ktory vyberie prihlaseny personal (ked si zaziada cestujuci zrusit listok)
@app.route('/deleteTicket', methods=['GET', 'POST'])
def deleteTicket():
    ticketToDelete = request.form['ticket']

    ticketToDelete = ticketToDelete.split(' ', 1)
    ticketToDelete = ticketToDelete[0]
    print(ticketToDelete)

    # odstranenie jizdenky podla id, ktore pride ako zvolena moznost od personalu, ktory na stranke vidi aj email usera
    cursor1 = connection.cursor()
    cursor1.execute("DELETE FROM Jizdenka WHERE id = '%s'" % ticketToDelete)
    connection.commit()
    cursor1.close()

    return ""


@app.route('/carrier', methods=['GET', 'POST'])
def carrier():
    carrierName = request.form['email']

    cursor = connection.cursor()
    cursor.execute("SELECT symbol from Symboly")
    symbols = cursor.fetchall()
    cursor.close()

    # vyhladam nazov dopravcu v DB a zistim tak id dopravcu
    cursor1 = connection.cursor()
    cursor1.execute("SELECT id FROM Dopravca WHERE email='%s';" % carrierName)
    idOfCarrier = cursor1.fetchone()
    cursor1.close()
    idOfCarrier = idOfCarrier[0]  # ziskanie z listu len prvy prvok - integer (id dopravcu)

    # ziskanie vsetkych len id vozidiel
    cursor1 = connection.cursor()
    cursor1.execute(
        "SELECT id FROM Vozidlo WHERE id_dopravca_vozidlo='%s';" % idOfCarrier)
    tmp_allIdsOfVehicles = cursor1.fetchall()
    cursor1.close()
    tmp_allIdsOfVehicles = list(tmp_allIdsOfVehicles)
    allIdsOfVehicles = []
    for m in tmp_allIdsOfVehicles:
        for n in m:
            allIdsOfVehicles.append(n)

    allVehicles = []
    for i in allIdsOfVehicles:
        tmp_allVehiclesdata = []
        # ziskam info o konkretnom vozidle
        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT id, pocet_miest, popis_vozidla, aktualna_poloha FROM Vozidlo WHERE id='%s';" % i)
        tmp_allInfoOfVehicle = cursor1.fetchone()
        cursor1.close()
        tmp_allInfoOfVehicle = list(tmp_allInfoOfVehicle)

        # ziskam spoje, cez ktore prechadza konkretne vozidlo
        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT id_spoju FROM Vozidlo_Spoj WHERE id_vozidla='%s';" % i)
        tmp_allConnectionsOfVehicle = cursor1.fetchall()
        cursor1.close()
        tmp_allConnectionsOfVehicle = list(tmp_allConnectionsOfVehicle)
        allIdsOfConnections = []
        for m in tmp_allConnectionsOfVehicle:
            for n in m:
                allIdsOfConnections.append(n)
        tmp_allInfoOfVehicle.append(allIdsOfConnections)
        allVehicles.append(tmp_allInfoOfVehicle)

    # ziskanie len id personalu
    cursor1 = connection.cursor()
    cursor1.execute(
        "SELECT id FROM Personal WHERE id_dopravca_personal='%s';" % idOfCarrier)
    tmp_allPersonalIds = cursor1.fetchall()
    cursor1.close()
    tmp_allPersonalIds = list(tmp_allPersonalIds)
    allPersonalIds = []
    for m in tmp_allPersonalIds:
        for n in m:
            allPersonalIds.append(n)

    allPersonal = []
    # ziskanie vsetkych uctov personalu daneho dopravcu
    for p in allPersonalIds:
        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT id, meno, priezvisko, email, heslo FROM Personal WHERE id='%s';" % p)
        tmp_allPersonalInfo = cursor1.fetchone()
        cursor1.close()
        tmp_allPersonalInfo = list(tmp_allPersonalInfo)

        # ziskam spoje, pre ktore pracuje personal
        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT id_spoju FROM Personal_Spoj WHERE id_personalu='%s';" % p)
        tmp_allConnectionsOfPersonal = cursor1.fetchall()
        cursor1.close()
        tmp_allConnectionsOfPersonal = list(tmp_allConnectionsOfPersonal)
        allConnectionsOfPersonal = []
        for m in tmp_allConnectionsOfPersonal:
            for n in m:
                allConnectionsOfPersonal.append(n)

        tmp_allPersonalInfo.append(allConnectionsOfPersonal)
        allPersonal.append(tmp_allPersonalInfo)

    allIdsOfConnectionsCarrier = []

    # ziskanie vsetkych spojov, ktore poskytuje dany dopravca
    # ziskanie vsetkych len id spojov
    cursor1 = connection.cursor()
    cursor1.execute(
        "SELECT id FROM Spoj WHERE id_dopravca_spoje='%s';" % idOfCarrier)
    tmp_allIdsOfConnections = cursor1.fetchall()
    cursor1.close()
    tmp_allIdsOfConnectionsCarrier = list(tmp_allIdsOfConnections)

    for m in tmp_allIdsOfConnectionsCarrier:
        for n in m:
            allIdsOfConnectionsCarrier.append(n)

    allConnections = []
    for i in allIdsOfConnectionsCarrier:
        allTimesSplitted = []
        tmp_fromAndToTime = []
        cities = []

        # ziskanie vsetkych casov, cez ktore spoj premava
        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT cas_prejazdu FROM Spoj_Zastavka WHERE id_spoju='%s';" % i)
        tmp_allTimes = cursor1.fetchall()
        cursor1.close()

        allTimes = []
        for m in tmp_allTimes:
            for n in m:
                allTimes.append(''.join(str(n)))

        # odstranenie ':' z casu
        for k in range(len(allTimes)):
            tmp2 = allTimes[k].replace(":", "")  # odstranenie ':' pre prevod na int
            tmp2 = int(tmp2)
            allTimesSplitted.append(tmp2)

        # sortovanie, aby boli spoje zoradene od najmensieho cisla po najvacsie pre zobrazenie
        allTimesSplitted.sort()
        timesWithColon = []
        for timeS in allTimesSplitted:
            if timeS <= 9:
                timeS = str(timeS)
                tmp_time = timeS[:0] + '0' + timeS[:3]
                tmp_time = tmp_time[:0] + '0' + tmp_time[:2]
                tmp_time = tmp_time[:1] + ':' + tmp_time[1:]
                timesWithColon.append(tmp_time)
            elif timeS <= 59:
                timeS = str(timeS)
                tmp_time = timeS[:0] + '0' + timeS[:4]
                tmp_time = tmp_time[:1] + ':' + tmp_time[1:]
                timesWithColon.append(tmp_time)
            elif timeS > 959:
                timeS = str(timeS)
                tmp_time = timeS[:2] + ':' + timeS[2:]
                timesWithColon.append(tmp_time)
            elif timeS <= 959:
                timeS = str(timeS)
                tmp_time = timeS[:1] + ':' + timeS[1:]
                timesWithColon.append(tmp_time)
        fromTime = str(timesWithColon[0])
        toTime = str(timesWithColon[-1])

        fromTime = str(fromTime)
        toTime = str(toTime)

        tmp_fromAndToTime.append(fromTime)
        tmp_fromAndToTime.append(toTime)
        for t in timesWithColon:
            cursor1 = connection.cursor()
            cursor1.execute("SELECT id_zastavky FROM Spoj_Zastavka WHERE id_spoju='%s' and cas_prejazdu='%s';" % (
                i, t))
            idOfStop = cursor1.fetchone()
            cursor1.close()
            idOfStop = idOfStop[0]

            cursor1 = connection.cursor()
            cursor1.execute(
                "SELECT nazov_zastavky FROM Zastavky WHERE id='%s';" % idOfStop)
            city = cursor1.fetchone()
            cursor1.close()
            city = list(city)
            city.append(t)
            cities.append(city)

        oneConnection = str(i) + ' | ' + cities[0][0] + ' ' + symbols[6][0] + ' ' + cities[-1][0]
        allConnections.append([oneConnection, cities])

    # ziskanie vsetkych nazvov zastavok pre dropdown menu pre vytvorenie noveho spoju - priprava
    cursor = connection.cursor()
    cursor.execute("SELECT nazov_zastavky from Zastavky")
    tmp = cursor.fetchall()
    cursor.close()
    allNamesOfCities = []
    for n in tmp:
        allNamesOfCities.append(''.join(n))

    # ziskanie vsetkych dostupnych vozidiel od daneho dopravcu, ktore nemaju pridelene ziadne spoje
    cursor = connection.cursor()
    cursor.execute("SELECT id from Vozidlo WHERE id_dopravca_vozidlo='%s';" % idOfCarrier)
    tmp_idOfAllVehicles = cursor.fetchall()
    cursor.close()
    idOfAllVehicles = []
    for m in tmp_idOfAllVehicles:
        for n in m:
            idOfAllVehicles.append(n)

    availableVehicles = []
    for i in idOfAllVehicles:
        # kontrolujem, ktore vozidla nemaju ziadny spoj zo vsetkych dopravcovych vozidiel
        cursor1 = connection.cursor()
        cursor1.execute("SELECT id_spoju FROM Vozidlo_Spoj WHERE id_vozidla='%s';" % i)
        hasConnection = cursor1.fetchone()
        cursor1.close()
        if hasConnection is None:
            availableVehicles.append(i)         # DOSTUPNE VOZIDLA

    # ziskanie dostupneho personalu od daneho dopravcu, ktory nema pridelene ziadny spoj
    cursor = connection.cursor()
    cursor.execute("SELECT id from Personal WHERE id_dopravca_personal='%s';" % idOfCarrier)
    tmp_idOfAllPersonal = cursor.fetchall()
    cursor.close()
    idOfAllPersonal = []
    for m in tmp_idOfAllPersonal:
        for n in m:
            idOfAllPersonal.append(n)

    availablePersonal = []
    for j in idOfAllPersonal:
        # kontrolujem, ktory personal nema ziadny spoj, v ktorom pracuje
        cursor1 = connection.cursor()
        cursor1.execute("SELECT id_spoju FROM Personal_Spoj WHERE id_personalu='%s';" % j)
        personalHasConnection = cursor1.fetchone()
        cursor1.close()
        if personalHasConnection is None:
            cursor1 = connection.cursor()
            cursor1.execute("SELECT meno, priezvisko FROM Personal WHERE id='%s';" % j)
            nameOfPersonal = cursor1.fetchone()
            cursor1.close()
            idAndNameOfPersonal = [j, nameOfPersonal]
            availablePersonal.append(idAndNameOfPersonal)  # DOSTUPNY PERSONAL

    availablePersonalAndVehicles = [availableVehicles, availablePersonal]

    data = {'vehicles': allVehicles, 'connections': allConnections,
            'personal': allPersonal, 'availablePersonalAndVehicles': availablePersonalAndVehicles}
    return render_template("carrier.html", data=data, cities=allNamesOfCities)
    # martin mi z vehicles posiela id a text vo formularoch pre editVehicleInfo
    # vymazanie vozidla - funkcia deleteVehicle, posiela len id a pole spojov cez ktore prechadza connections
    # /editPersonalInfo pre zmenu info o zamestnancovi - id, fname, lname, email, ids
    # /deletePersonal, posiela mi id daneho zamestnanca
    # /deleteConnection posiela mi id - je to string ktory treba splitnut a vybrat z toho to id

# funkcia pre upravu popisu vozidla
@app.route('/editVehicleInfo', methods=['GET', 'POST'])
def editVehicleInfo():
    idOfVehicle = request.form['id']
    newDescriptionOfVehicle = request.form['text']
    print(idOfVehicle, newDescriptionOfVehicle)

    # aktualizacia popisu konkretneho vozidla
    cursor1 = connection.cursor()
    cursor1.execute("UPDATE Vozidlo SET popis_vozidla = '%s' WHERE id = '%s'" % (newDescriptionOfVehicle, idOfVehicle))
    connection.commit()
    cursor1.close()

    return ''

# funkcia pre upravu popisu vozidla
@app.route('/deleteVehicle', methods=['GET', 'POST'])
def deleteVehicle():
    idOfVehicle = request.form['id']
    connectionsOfVehicle = request.form['connections']
    listOfAllConnectionsToDelete = connectionsOfVehicle.split(' ')
    listOfAllConnectionsToDelete.remove('')

    for i in listOfAllConnectionsToDelete:
        # odstranenie zaznamu z tabulky Personal_Spoj
        cursor1 = connection.cursor()
        cursor1.execute("DELETE FROM Personal_Spoj WHERE id_spoju = '%s'" % i)
        connection.commit()
        cursor1.close()

        # odstranenie zaznamu z tabulky Spoj
        cursor1 = connection.cursor()
        cursor1.execute("DELETE FROM Spoj WHERE id = '%s'" % i)
        connection.commit()
        cursor1.close()

        # odstranenie zaznamu z tabulky Spoj_Zastavka
        cursor1 = connection.cursor()
        cursor1.execute("DELETE FROM Spoj_Zastavka WHERE id_spoju = '%s'" % i)
        connection.commit()
        cursor1.close()

        # odstranenie zaznamu z tabulky Vozidlo_Spoj
        cursor1 = connection.cursor()
        cursor1.execute("DELETE FROM Vozidlo_Spoj WHERE id_spoju = '%s'" % i)
        connection.commit()
        cursor1.close()

    # odstranenie konkretneho vozidla, podla id
    cursor1 = connection.cursor()
    cursor1.execute("DELETE FROM Vozidlo WHERE id = '%s'" % idOfVehicle)
    connection.commit()
    cursor1.close()

    return ''

# funkcia pre pridanie noveho vozidla
@app.route('/addVehicle', methods=['GET', 'POST'])
def addVehicle():
    numberOfSeats = request.form['seats']
    descriptionOfVehicle = request.form['text']
    carrierEmail = request.form['carrier']

    # ziskanie id dopravcu, ktory pridava nove vozidlo
    cursor1 = connection.cursor()
    cursor1.execute("SELECT id FROM Dopravca WHERE email='%s';" % carrierEmail)
    idOfCarrier = cursor1.fetchone()
    cursor1.close()
    idOfCarrier = idOfCarrier[0]

    # pridanie noveho vozidla dopravcom
    cursor = connection.cursor()
    cursor.execute(
        "insert into `Vozidlo` (pocet_miest, popis_vozidla, id_dopravca_vozidlo) VALUES (%s, %s, %s)",
        (numberOfSeats, descriptionOfVehicle, idOfCarrier))
    connection.commit()
    cursor.close()

    return ''

# funkcia pre upravu uctu personalu
@app.route('/editPersonalInfo', methods=['GET', 'POST'])
def editPersonalInfo():
    idOfPersonal = request.form['id']
    fname = request.form['fname']
    lname = request.form['lname']
    email = request.form['email']
    idsOfConnections = request.form['ids']
    # odstranenie prazdnych hodnot z pola, aby mi zostalo len pole hodnot id spojov
    idsOfConnections = idsOfConnections.split(' ')
    valueToBeRemoved = ''
    idsOfConnections = [value for value in idsOfConnections if value != valueToBeRemoved]

    # aktualizacia uctu konkretneho personalu dopravcu
    cursor1 = connection.cursor()
    cursor1.execute("UPDATE Personal SET meno = '%s', priezvisko = '%s', email = '%s' WHERE id = '%s'" % (fname, lname, email, idOfPersonal))
    connection.commit()
    cursor1.close()

    # TODO skontrolovat, ci sa zmenili jej spoje (z toho pola co mi posiela martin a z toho co je v DB debinovane), na ktorych pracuje a update, pripadne delete
    # TODO ale co ak na spoji nebude zrazu ziadny personal? take spoje by sa asi nemali zobrazovat, asi ze?
    # riesene tu nizsie


    if len(idsOfConnections) == 0:
        print('empty')
    elif len(idsOfConnections) == 1:
        print('one')
    elif len(idsOfConnections) >= 2:
        print('more than one')


    return ''

# funkcia pre pridanie noveho uctu personalu
@app.route('/addPersonal', methods=['GET', 'POST'])
def addPersonal():
    fname = request.form['fname']
    lname = request.form['lname']
    email = request.form['email']
    password = request.form['password']
    allIdsOfConnectionsPersonal = request.form['ids']
    carrierEmail = request.form['carrier']
    allIdsOfConnectionsPersonal = allIdsOfConnectionsPersonal.split(' ')
    allIdsOfConnectionsPersonal.remove('')

    cursor1 = connection.cursor()
    cursor1.execute("SELECT id FROM Dopravca WHERE email='%s';" % carrierEmail)
    idOfCarrier = cursor1.fetchone()  # ziskanie id_dopravcu_spoje
    cursor1.close()
    idOfCarrier = idOfCarrier[0]

    # vytvorenie noveho uctu do Personal
    cursor = connection.cursor()
    cursor.execute("insert into `Personal` (meno, priezvisko, email, heslo, id_dopravca_personal) VALUES (%s, %s, %s, %s, %s)",
            (fname, lname, email, password, idOfCarrier))
    connection.commit()
    cursor.close()

    cursor1 = connection.cursor()
    cursor1.execute("SELECT id FROM Personal WHERE email='%s';" % email)
    idOfNewPersonal = cursor1.fetchone()
    cursor1.close()
    idOfNewPersonal = idOfNewPersonal[0]

    # namapovanie id spojov na konkretneho noveho uzivatela
    for i in allIdsOfConnectionsPersonal:
        cursor = connection.cursor()
        cursor.execute(
            "insert into `Personal_Spoj` (id_personalu, id_spoju) VALUES (%s, %s)",
            (idOfNewPersonal, i))
        connection.commit()
        cursor.close()

    return ""


# funkcia pre vymazanie uctu personalu
@app.route('/deletePersonal', methods=['GET', 'POST'])
def deletePersonal():
    idOfPersonal = request.form['id']

    # odstranenie vsetkych zaznamov v spojoch, ktore obsluhoval personal - spoje samostatne ostavaju v tabulke ale nemmusia uz mat ziadny personal
    cursor1 = connection.cursor()
    cursor1.execute("DELETE FROM Personal_Spoj WHERE id_personalu = '%s'" % idOfPersonal)
    connection.commit()
    cursor1.close()

    # odstranenie uctu personalu dopravcom
    cursor1 = connection.cursor()
    cursor1.execute("DELETE FROM Personal WHERE id = '%s'" % idOfPersonal)
    connection.commit()
    cursor1.close()

    return ''

# funkcia pre navrh novej zastavky navrhovanu od dopravcu
@app.route('/addConnection', methods=['GET', 'POST'])
def addConnection():

    return ''


# funkcia pre navrh novej zastavky navrhovanu od dopravcu
@app.route('/addStop', methods=['GET', 'POST'])
def addStop():
    carrierEmail = request.form['carrier']
    nameOfConnection = request.form['name']
    sirkaGEO = request.form['latitude']
    vyskaGEO = request.form['longtitude']

    GeoLocation = sirkaGEO + ', ' + vyskaGEO

    # ziskanie id dopravcu podla emailu
    cursor1 = connection.cursor()
    cursor1.execute("SELECT id FROM Dopravca WHERE email='%s';" % carrierEmail)
    idOfCarrier = cursor1.fetchone()  # ziskanie id_dopravcu_spoje
    cursor1.close()
    idOfCarrier = idOfCarrier[0]

    # vytvaram novy navrh o zastavke, navrhovany konkretnym dopravcom
    cursor = connection.cursor()
    cursor.execute("insert into `NavrhZastavky` (nazov, geograficka_poloha, id_dopravca_navrhy, stav) VALUES (%s, %s, %s, %s)",
                   (nameOfConnection, GeoLocation, idOfCarrier, 'nepotvrdena'))
    connection.commit()
    cursor.close()

    return ''

@app.route('/administrator', methods=['GET', 'POST'])
def administrator():
    carrierName = request.form['email']

    cursor = connection.cursor()
    cursor.execute("SELECT symbol from Symboly")
    symbols = cursor.fetchall()
    cursor.close()

    # vyhladam nazov dopravcu v DB a zistim tak id dopravcu
    cursor1 = connection.cursor()
    cursor1.execute("SELECT id FROM Dopravca WHERE email='%s';" % carrierName)
    idOfCarrier = cursor1.fetchone()
    cursor1.close()
    idOfCarrier = idOfCarrier[0]  # ziskanie z listu len prvy prvok - integer (id dopravcu)

    # ziskanie vsetkych len id vozidiel
    cursor1 = connection.cursor()
    cursor1.execute(
        "SELECT id FROM Vozidlo WHERE id_dopravca_vozidlo='%s';" % idOfCarrier)
    tmp_allIdsOfVehicles = cursor1.fetchall()
    cursor1.close()
    tmp_allIdsOfVehicles = list(tmp_allIdsOfVehicles)
    allIdsOfVehicles = []
    for m in tmp_allIdsOfVehicles:
        for n in m:
            allIdsOfVehicles.append(n)

    allVehicles = []
    for i in allIdsOfVehicles:
        tmp_allVehiclesdata = []
        # ziskam info o konkretnom vozidle
        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT id, pocet_miest, popis_vozidla, aktualna_poloha FROM Vozidlo WHERE id='%s';" % i)
        tmp_allInfoOfVehicle = cursor1.fetchone()
        cursor1.close()
        tmp_allInfoOfVehicle = list(tmp_allInfoOfVehicle)

        # ziskam spoje, cez ktore prechadza konkretne vozidlo
        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT id_spoju FROM Vozidlo_Spoj WHERE id_vozidla='%s';" % i)
        tmp_allConnectionsOfVehicle = cursor1.fetchall()
        cursor1.close()
        tmp_allConnectionsOfVehicle = list(tmp_allConnectionsOfVehicle)
        allIdsOfConnections = []
        for m in tmp_allConnectionsOfVehicle:
            for n in m:
                allIdsOfConnections.append(n)
        tmp_allInfoOfVehicle.append(allIdsOfConnections)
        allVehicles.append(tmp_allInfoOfVehicle)

    # ziskanie len id personalu
    cursor1 = connection.cursor()
    cursor1.execute(
        "SELECT id FROM Personal WHERE id_dopravca_personal='%s';" % idOfCarrier)
    tmp_allPersonalIds = cursor1.fetchall()
    cursor1.close()
    tmp_allPersonalIds = list(tmp_allPersonalIds)
    allPersonalIds = []
    for m in tmp_allPersonalIds:
        for n in m:
            allPersonalIds.append(n)

    allPersonal = []
    # ziskanie vsetkych uctov personalu daneho dopravcu
    for p in allPersonalIds:
        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT id, meno, priezvisko, email, heslo FROM Personal WHERE id='%s';" % p)
        tmp_allPersonalInfo = cursor1.fetchone()
        cursor1.close()
        tmp_allPersonalInfo = list(tmp_allPersonalInfo)

        # ziskam spoje, pre ktore pracuje personal
        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT id_spoju FROM Personal_Spoj WHERE id_personalu='%s';" % p)
        tmp_allConnectionsOfPersonal = cursor1.fetchall()
        cursor1.close()
        tmp_allConnectionsOfPersonal = list(tmp_allConnectionsOfPersonal)
        allConnectionsOfPersonal = []
        for m in tmp_allConnectionsOfPersonal:
            for n in m:
                allConnectionsOfPersonal.append(n)

        tmp_allPersonalInfo.append(allConnectionsOfPersonal)
        allPersonal.append(tmp_allPersonalInfo)

    allIdsOfConnectionsCarrier = []

    # ziskanie vsetkych spojov, ktore poskytuje dany dopravca
    # ziskanie vsetkych len id spojov
    cursor1 = connection.cursor()
    cursor1.execute(
        "SELECT id FROM Spoj WHERE id_dopravca_spoje='%s';" % idOfCarrier)
    tmp_allIdsOfConnections = cursor1.fetchall()
    cursor1.close()
    tmp_allIdsOfConnectionsCarrier = list(tmp_allIdsOfConnections)

    for m in tmp_allIdsOfConnectionsCarrier:
        for n in m:
            allIdsOfConnectionsCarrier.append(n)

    allConnections = []
    for i in allIdsOfConnectionsCarrier:
        allTimesSplitted = []
        tmp_fromAndToTime = []
        cities = []

        # ziskanie vsetkych casov, cez ktore spoj premava
        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT cas_prejazdu FROM Spoj_Zastavka WHERE id_spoju='%s';" % i)
        tmp_allTimes = cursor1.fetchall()
        cursor1.close()

        allTimes = []
        for m in tmp_allTimes:
            for n in m:
                allTimes.append(''.join(str(n)))

        # odstranenie ':' z casu
        for k in range(len(allTimes)):
            tmp2 = allTimes[k].replace(":", "")  # odstranenie ':' pre prevod na int
            tmp2 = int(tmp2)
            allTimesSplitted.append(tmp2)

        # sortovanie, aby boli spoje zoradene od najmensieho cisla po najvacsie pre zobrazenie
        allTimesSplitted.sort()
        timesWithColon = []
        for timeS in allTimesSplitted:
            if timeS <= 9:
                timeS = str(timeS)
                tmp_time = timeS[:0] + '0' + timeS[:3]
                tmp_time = tmp_time[:0] + '0' + tmp_time[:2]
                tmp_time = tmp_time[:1] + ':' + tmp_time[1:]
                timesWithColon.append(tmp_time)
            elif timeS <= 59:
                timeS = str(timeS)
                tmp_time = timeS[:0] + '0' + timeS[:4]
                tmp_time = tmp_time[:1] + ':' + tmp_time[1:]
                timesWithColon.append(tmp_time)
            elif timeS > 959:
                timeS = str(timeS)
                tmp_time = timeS[:2] + ':' + timeS[2:]
                timesWithColon.append(tmp_time)
            elif timeS <= 959:
                timeS = str(timeS)
                tmp_time = timeS[:1] + ':' + timeS[1:]
                timesWithColon.append(tmp_time)
        fromTime = str(timesWithColon[0])
        toTime = str(timesWithColon[-1])

        fromTime = str(fromTime)
        toTime = str(toTime)

        tmp_fromAndToTime.append(fromTime)
        tmp_fromAndToTime.append(toTime)
        for t in timesWithColon:
            cursor1 = connection.cursor()
            cursor1.execute("SELECT id_zastavky FROM Spoj_Zastavka WHERE id_spoju='%s' and cas_prejazdu='%s';" % (
                i, t))
            idOfStop = cursor1.fetchone()
            cursor1.close()
            idOfStop = idOfStop[0]

            cursor1 = connection.cursor()
            cursor1.execute(
                "SELECT nazov_zastavky FROM Zastavky WHERE id='%s';" % idOfStop)
            city = cursor1.fetchone()
            cursor1.close()
            city = list(city)
            city.append(t)
            cities.append(city)

        oneConnection = str(i) + ' | ' + cities[0][0] + ' ' + symbols[6][0] + ' ' + cities[-1][0]
        allConnections.append([oneConnection, cities])

    # ziskanie vsetkych nazvov zastavok pre dropdown menu pre vytvorenie noveho spoju - priprava
    cursor = connection.cursor()
    cursor.execute("SELECT nazov_zastavky from Zastavky")
    tmp = cursor.fetchall()
    cursor.close()
    allNamesOfCities = []
    for n in tmp:
        allNamesOfCities.append(''.join(n))

    # ziskanie vsetkych dostupnych vozidiel od daneho dopravcu, ktore nemaju pridelene ziadne spoje
    cursor = connection.cursor()
    cursor.execute("SELECT id from Vozidlo WHERE id_dopravca_vozidlo='%s';" % idOfCarrier)
    tmp_idOfAllVehicles = cursor.fetchall()
    cursor.close()
    idOfAllVehicles = []
    for m in tmp_idOfAllVehicles:
        for n in m:
            idOfAllVehicles.append(n)

    availableVehicles = []
    for i in idOfAllVehicles:
        # kontrolujem, ktore vozidla nemaju ziadny spoj zo vsetkych dopravcovych vozidiel
        cursor1 = connection.cursor()
        cursor1.execute("SELECT id_spoju FROM Vozidlo_Spoj WHERE id_vozidla='%s';" % i)
        hasConnection = cursor1.fetchone()
        cursor1.close()
        if hasConnection is None:
            availableVehicles.append(i)         # DOSTUPNE VOZIDLA

    # ziskanie dostupneho personalu od daneho dopravcu, ktory nema pridelene ziadny spoj
    cursor = connection.cursor()
    cursor.execute("SELECT id from Personal WHERE id_dopravca_personal='%s';" % idOfCarrier)
    tmp_idOfAllPersonal = cursor.fetchall()
    cursor.close()
    idOfAllPersonal = []
    for m in tmp_idOfAllPersonal:
        for n in m:
            idOfAllPersonal.append(n)

    availablePersonal = []
    for j in idOfAllPersonal:
        # kontrolujem, ktory personal nema ziadny spoj, v ktorom pracuje
        cursor1 = connection.cursor()
        cursor1.execute("SELECT id_spoju FROM Personal_Spoj WHERE id_personalu='%s';" % j)
        personalHasConnection = cursor1.fetchone()
        cursor1.close()
        if personalHasConnection is None:
            cursor1 = connection.cursor()
            cursor1.execute("SELECT meno, priezvisko FROM Personal WHERE id='%s';" % j)
            nameOfPersonal = cursor1.fetchone()
            cursor1.close()
            idAndNameOfPersonal = [j, nameOfPersonal]
            availablePersonal.append(idAndNameOfPersonal)  # DOSTUPNY PERSONAL

    availablePersonalAndVehicles = [availableVehicles, availablePersonal]

    # ziskanie vsetkych nazvov dopravcov, z ktorych si admin zvoli jedneho, za ktoreho bude vykonavat zmeny v systeme
    cursor = connection.cursor()
    cursor.execute("SELECT nazov from Dopravca")
    tmp_names = cursor.fetchall()
    cursor.close()

    allCarriers = []
    for m in tmp_names:
        for n in m:
            allCarriers.append(n)

    allSuggestions = 'nothing'


    data = {'vehicles': allVehicles, 'connections': allConnections,
            'personal': allPersonal, 'availablePersonalAndVehicles': availablePersonalAndVehicles, 'carriers': allCarriers, 'suggestions': allSuggestions}
    return render_template("administrator.html", data=data, cities=allNamesOfCities)


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

                        # ziskanie poctu volnych dostupnych miest v danom spoji daneho vozidla
                        cursor1 = connection.cursor()
                        cursor1.execute("SELECT id_vozidla FROM Vozidlo_Spoj WHERE id_spoju='%s';" % row1[1])
                        id_vozidla = cursor1.fetchone()
                        cursor1.close()
                        cursor1 = connection.cursor()
                        cursor1.execute("SELECT pocet_miest FROM Vozidlo WHERE id='%s';" % id_vozidla)
                        availableSeats = cursor1.fetchone()
                        cursor1.close()

                        # ziskanie popisu vozidla aktualneho spoju
                        cursor1 = connection.cursor()
                        cursor1.execute("SELECT popis_vozidla FROM Vozidlo WHERE id='%s';" % id_vozidla)
                        vehicleDescription = cursor1.fetchone()
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
                            # zistenie, kolko volnych miest dany spoj este ponuka na predaj
                            cursor1 = connection.cursor()
                            cursor1.execute(
                                "SELECT pocet_miest FROM Jizdenka WHERE datum='%s' and id_spoj_jizdenky='%s';" % (
                                    dateAndDayOfConnection, connectionNumber))
                            tmp_reservedNumberOfSeats = cursor1.fetchall()
                            cursor1.close()
                            reservedNumberOfSeats = []
                            for i in tmp_reservedNumberOfSeats:
                                for j in i:
                                    reservedNumberOfSeats.append(int(''.join(str(j))))
                            reservedNumberOfSeats = sum(reservedNumberOfSeats)
                            print(availableSeats, reservedNumberOfSeats)
                            availableSeats -= reservedNumberOfSeats
                            if availableSeats < 0:
                                availableSeats = 0
                            possibleBusConnections.append(
                                [connectionNumber, fromCity, fromCityTime, toCity, toCityTime, carrier_name,
                                 availableSeats, dateAndDayOfConnection, connectionTimeHours, priceOfConnection,
                                 allCitiesOfConnection, tmp_timeFromCity, vehicleDescription])
                            counterOfConnections += 1
                            possibleBusConnections.sort(key=lambda y: y[
                                11])  # sortovanie, aby boli spoje zoradene od najmensieho cisla po najvacsie pre zobrazenie
                        if nextDay:  # pre dalsie spoje, na dalsi den - rovnake spoje, len datum o cislo vyssi a od zaciatku dna 00:00 vsetky, nie len najblizsie v dany den
                            # zistenie, kolko volnych miest dany spoj este ponuka na predaj
                            cursor1 = connection.cursor()
                            cursor1.execute(
                                "SELECT pocet_miest FROM Jizdenka WHERE datum='%s' and id_spoj_jizdenky='%s';" % (
                                    dateAndDayOfConnection, connectionNumber))
                            tmp_reservedNumberOfSeats = cursor1.fetchall()
                            cursor1.close()
                            reservedNumberOfSeats = []
                            for i in tmp_reservedNumberOfSeats:
                                for j in i:
                                    reservedNumberOfSeats.append(int(''.join(str(j))))
                            reservedNumberOfSeats = sum(reservedNumberOfSeats)
                            availableSeats -= reservedNumberOfSeats
                            if availableSeats < 0:
                                availableSeats = 0
                            laterPossibleBusConnections.append(
                                [connectionNumber, fromCity, fromCityTime, toCity, toCityTime, carrier_name,
                                 availableSeats, dateAndDayOfConnection, connectionTimeHours, priceOfConnection,
                                 allCitiesOfConnection, tmp_timeFromCity, vehicleDescription])
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
    global profileNameMainPage
    user_email = str(request.form['lEmail'])
    password = str(request.form['lPassword'])
    # kontrola spravnosti prihlasovacich udajov z webu a DB
    cestujuci = connection.cursor()
    administrator = connection.cursor()
    personal = connection.cursor()
    carrier = connection.cursor()
    cestujuci.execute("SELECT meno, email, heslo FROM Cestujuci")
    administrator.execute("SELECT meno, email, heslo FROM Administrator")
    personal.execute("SELECT meno, email, heslo FROM Personal")
    carrier.execute("SELECT nazov, email, heslo FROM Dopravca")
    for (meno, email, heslo) in cestujuci:
        if email == user_email and heslo == password:
            cestujuci.close()
            profileNameMainPage = meno
            loginData = {'message': 'login', 'email': user_email, 'status': 'cestujuci'}
            return redirect(url_for('index'))
    for (meno, email, heslo) in administrator:
        if email == user_email and heslo == password:
            administrator.close()
            profileNameMainPage = meno
            loginData = {'message': 'login', 'email': user_email, 'status': 'administrator'}
            return redirect(url_for('index'))
    for (meno, email, heslo) in personal:
        if email == user_email and heslo == password:
            personal.close()
            profileNameMainPage = meno
            loginData = {'message': 'login', 'email': user_email, 'status': 'personal'}
            return redirect(url_for('index'))
    for (nazov, email, heslo) in carrier:
        if email == user_email and heslo == password:
            carrier.close()
            profileNameMainPage = nazov
            loginData = {'message': 'login', 'email': user_email, 'status': 'carrier'}
            return redirect(url_for('index'))
    cestujuci.close()
    administrator.close()
    personal.close()
    carrier.close()

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
    global profileNameMainPage
    fname = request.form['fname']
    lname = request.form['lname']
    user_email = request.form['email']
    password = request.form['password']

    cursor = connection.cursor()
    cursor.execute("SELECT email FROM Cestujuci")
    for (email) in cursor:
        email = ''.join(email)
        if email == user_email:
            cursor1 = connection.cursor()
            cursor1.execute("SELECT heslo FROM Cestujuci WHERE email='%s';" % email)
            passwordOfEmail = cursor1.fetchone()
            cursor1.close()
            cursor.close()
            passwordOfEmail = passwordOfEmail[0]
            if passwordOfEmail != ' ':
                data = {'error': 'reg', 'email': user_email}
                return render_template('signIn.html', data=data)
    cursor.close()

    cursor = connection.cursor()
    cursor.execute("insert into `Cestujuci` (meno, priezvisko, email, heslo) VALUES (%s, %s, %s, %s)",
                   (fname, lname, user_email, password))
    connection.commit()
    cursor.close()
    profileNameMainPage = fname
    loginData = {'message': 'login', 'email': user_email, 'status': 'cestujuci'}
    return redirect(url_for('index'))


# DOPRAVCA - navrhovanie novych zastavok
# tato funkcia zobrazi vsetky zastavky, ktore existuju a aj ich data aby ich mohol pr
@app.route('/loadStops', methods=['GET', 'POST'])
def loadStops():
    # ziskanie vsetkych zastavok, aby dopravca nahodou nepridal zastavku, ktora uz existuje
    cursor1 = connection.cursor()
    cursor1.execute("SELECT id, nazov_zastavky, geograficka_poloha FROM Zastavky")
    allStops = cursor1.fetchall()
    cursor1.close()
    allStops = list(allStops)
    print(allStops)

    # ziskanie vsetkych navrhov zastavok, ich geografickych poloh a ich id
    cursor1 = connection.cursor()
    cursor1.execute(
        "SELECT id, nazov, geograficka_poloha, id_dopravca_navrhy, stav FROM NavrhZastavky WHERE stav='potvrdena';")
    allSuggestedStops = cursor1.fetchall()
    cursor1.close()
    allSuggestedStops = list(allSuggestedStops)
    print(allSuggestedStops)

    return ""


# DOPRAVCA - ulozenie info o navrhu novej zastavky, ktore bude schvalovat administrator
@app.route('/newSuggestStop', methods=['GET', 'POST'])
def newSuggestStop():
    # TODO tu mi pridu data od Martina - potrebujem z formularu NAZOV, GEO.POLOHU, MENO DOPRAVCU KTORY TO NAVRHUJE

    # pridanie navrhu do DB
    # cursor1 = connection.cursor()
    # cursor1.execute(
    #    "insert into `NavrhZastavky` (nazov, geograficka_poloha, id_dopravca_navrhy, stav, id_administrator_potvrdenie) VALUES (%s, %s, %s, %s, %s)",
    #    (, , , , , ))
    # connection.commit()
    # cursor1.close()
    return


# ADMIN - zobrazenie vsetkych uctov
@app.route('/loadUsers/', methods=['GET', 'POST'])
def loadUsers():
    # popis fce: zobrazenie vsetkych uzivatelskych uctov cestujucich

    # zobrazenie vsetkych uctov a ulozenie do 2D zoznamu
    allUsers = []
    cursor1 = connection.cursor()
    cursor1.execute("SELECT meno, priezvisko, email, heslo FROM Administrator")
    tmp_allUsers = cursor1.fetchall()
    cursor1.close()
    allUsers.append(list(tmp_allUsers))

    cursor1 = connection.cursor()
    cursor1.execute("SELECT nazov, email, heslo FROM Dopravca")
    tmp_allUsers = cursor1.fetchall()
    cursor1.close()
    allUsers.append(list(tmp_allUsers))

    cursor1 = connection.cursor()
    cursor1.execute("SELECT meno, priezvisko, email, heslo FROM Personal")
    tmp_allUsers = cursor1.fetchall()
    cursor1.close()
    allUsers.append(list(tmp_allUsers))

    cursor1 = connection.cursor()
    cursor1.execute("SELECT meno, priezvisko, email, heslo FROM Cestujuci")
    tmp_allUsers = cursor1.fetchall()
    cursor1.close()
    allUsers.append(list(tmp_allUsers))

    # allUsers[0] - administrator ucty
    # allUsers[1] - dopravca ucty
    # allUsers[2] - personal ucty
    # allUsers[3] - cestujuci ucty

    return render_template("XXXXX.html", data=allUsers)


# kontrola pri nakupe listka ci uzivatel klikol na registrovat alebo prihlasit
@app.route('/validate/<regOrSignIn>', methods=['GET', 'POST'])
def validate(regOrSignIn):
    global loginData
    global profileNameMainPage
    user_email = request.form['email']
    if regOrSignIn == 'signIn':
        password = request.form['password']
        # kontrola spravnosti prihlasovacich udajov z webu a DB
        cestujuci = connection.cursor()
        administrator = connection.cursor()
        personal = connection.cursor()
        carrier = connection.cursor()
        cestujuci.execute("SELECT meno, email, heslo FROM Cestujuci")
        administrator.execute("SELECT meno, email, heslo FROM Administrator")
        personal.execute("SELECT meno, email, heslo FROM Personal")
        carrier.execute("SELECT nazov, email, heslo FROM Dopravca")
        for (meno, email, heslo) in cestujuci:
            if email == user_email and heslo == password:
                cestujuci.close()
                profileNameMainPage = meno
                loginData = 'cestujuci+' + profileNameMainPage
                # loginData = json.dumps(loginData)
                return loginData
        for (meno, email, heslo) in administrator:
            if email == user_email and heslo == password:
                administrator.close()
                profileNameMainPage = meno
                loginData = 'administrator+' + profileNameMainPage
                # loginData = json.dumps(loginData)
                return loginData
        for (meno, email, heslo) in personal:
            if email == user_email and heslo == password:
                personal.close()
                profileNameMainPage = meno
                loginData = 'personal+' + profileNameMainPage
                # loginData = json.dumps(loginData)
                return loginData
        for (nazov, email, heslo) in carrier:
            if email == user_email and heslo == password:
                carrier.close()
                profileNameMainPage = nazov
                loginData = 'carrier+' + profileNameMainPage
                return loginData
        cestujuci.close()
        administrator.close()
        personal.close()
        carrier.close()
        data = 'log'
        # data = json.dumps(data)
        return data

    if regOrSignIn == 'register':
        cursor = connection.cursor()
        cursor.execute("SELECT email FROM Cestujuci")
        for (email) in cursor:
            email = ''.join(email)
            if email == user_email:
                cursor1 = connection.cursor()
                cursor1.execute("SELECT heslo FROM Cestujuci WHERE email='%s';" % email)
                passwordOfEmail = cursor1.fetchone()
                cursor1.close()
                passwordOfEmail = passwordOfEmail[0]
                cursor.close()
                if passwordOfEmail != ' ':
                    data = 'reg'
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

    if signedInOrOneTime == 'register' or signedInOrOneTime == 'signIn' or signedInOrOneTime == 'signedIn':
        # Generovanie PDF
        generatePDF(fname, lname, numberOfConnection, date, numberOfTickets, cities[0], timeFromCity, cities[1],
                    timeToCity,
                    carrier_name, user_email, idOfTicket)

        return tickets()
    if signedInOrOneTime == 'oneTime':
        data = []
        idOfTicket = str(idOfTicket[0])
        generatePDF(fname, lname, numberOfConnection, date, numberOfTickets, cities[0], timeFromCity, cities[1],
                    timeToCity,
                    carrier_name, user_email, idOfTicket)

        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT id_vozidla FROM Vozidlo_Spoj WHERE id_spoju='%s';" % numberOfConnection)
        idOfVehicle = cursor1.fetchone()
        idOfVehicle = idOfVehicle[0]
        cursor1.close()

        cursor1 = connection.cursor()
        cursor1.execute(
            "SELECT aktualna_poloha FROM Vozidlo WHERE id='%s';" % idOfVehicle)
        currentLocation = cursor1.fetchone()
        currentLocation = currentLocation[0]
        cursor1.close()

        data.append([user_email, idOfTicket, currentLocation])
        print(data)

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
    if type(idOfTicket) == tuple:
        idOfTicket = idOfTicket[0]
    if type(idOfTicket) == int:
        idOfTicket = str(idOfTicket)
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
    pdf.output(savePDFname, 'F')
    return


def databaseCheck():
    try:
        conn = pymysql.connect(host='92.52.58.251', user='admin', password='password', db='iis')
    except pymysql.Error as error:
        webhookUrl = 'https://maker.ifttt.com/trigger/error/with/key/jglncn-jhDn3EyEKlB3nkuB2VDNC8Rs4Fuxg5IpNE4'
        requests.post(webhookUrl, headers={'Content-Type': 'application/json'})
        print("Cannot connect to database.")

    # ziskanie vsetkych id jizdeniek
    cursor = conn.cursor()
    cursor.execute("SELECT id from Jizdenka")
    tmp_ids = cursor.fetchall()
    cursor.close()

    allIds = []
    for m in tmp_ids:
        for n in m:
            allIds.append(n)

    # ziskanie vsetkych id jizdeniek
    cursor = conn.cursor()
    cursor.execute("SELECT id_cestujuci_jizdenka from Jizdenka")
    tmp_passenger_ids = cursor.fetchall()
    cursor.close()

    allPassengerIds = []
    for m in tmp_passenger_ids:
        for n in m:
            allPassengerIds.append(n)

    tmp_emails = []
    for i in reversed(range(len(allPassengerIds))):
        # ziskanie vsetkych emailov
        cursor = connection.cursor()
        cursor.execute("SELECT email from Cestujuci WHERE id=%s" % allPassengerIds[i])
        tmp_emails.append(cursor.fetchall())
        cursor.close()

    allEmails = []
    for m in tmp_emails:
        for n in m:
            for o in n:
                allEmails.append(''.join(str(o)))

    allEmailsWithIdsPdf = []
    allEmailsWithIdsPng = []
    allIds.sort()
    for i in range(len(allEmails)):
        idAndEmailPdf = allEmails[i] + '_' + str(allIds[i]) + '.pdf'  # format nazvu stiahnuteho listku: email_id.pdf
        allEmailsWithIdsPdf.append(idAndEmailPdf)
        idAndEmailPng = allEmails[i] + '_' + str(allIds[i]) + '.png'  # format nazvu stiahnuteho listku: email_id.pdf
        allEmailsWithIdsPng.append(idAndEmailPng)

    boolRemoveTicket = True
    for item in os.listdir(os.path.dirname(os.path.realpath(__file__)) + '/static/tickets/'):
        if os.path.isfile(os.path.join(os.path.dirname(os.path.realpath(__file__)) + '/static/tickets/', item)):
            for k in allEmailsWithIdsPdf:
                if k == item:
                    boolRemoveTicket = False
            if boolRemoveTicket:
                removeTicket = os.path.dirname(os.path.realpath(__file__)) + '/static/tickets/' + item
                os.remove(removeTicket)
            boolRemoveTicket = True

    for item in os.listdir(os.path.dirname(os.path.realpath(__file__)) + '/static/qr/'):
        if os.path.isfile(os.path.join(os.path.dirname(os.path.realpath(__file__)) + '/static/qr/', item)):
            for k in allEmailsWithIdsPng:
                if k == item:
                    boolRemoveTicket = False
            if boolRemoveTicket:
                removeTicket = os.path.dirname(os.path.realpath(__file__)) + '/static/qr/' + item
                os.remove(removeTicket)
            boolRemoveTicket = True


if __name__ == '__main__':
    scheduler = BackgroundScheduler()
    job = scheduler.add_job(databaseCheck, 'interval', minutes=5)
    scheduler.start()
    app.run(debug=True)
