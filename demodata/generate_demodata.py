# Author: Razvan Hrestic
# Universitaet der Bundeswehr Muenchen
import json 
import random
import http.client
import mimetypes
import requests
import os
import time
import getpass
from consolemenu import *
from consolemenu.items import *

currentToken = 'NONE'
ORGANIZATIONS_LIST = ["DeoniMSP","BrangusMSP","PinzgauerMSP","AuthorityMSP","DurocMSP"]
SECONDS_TO_WAIT_FOR_HTTP_REQUESTS = 30
apiPassword = ''


def save_object(obj, filename):
    with open(filename, 'wb') as output:  # Overwrites any existing file.
        json.dump(obj, output)

def init_demo_datastructures():
    read_api_password()
    init_demo_attributes()
    init_demo_units()
    init_demo_objects()
    
def generate_random_objects():
    milkObjects = generate_demo_objects( 'milk', 'milklot_product_template.json' )
    cheeseObjects = generate_demo_objects( 'cheese', 'cheese_product_template.json' )   
    generate_object_links_produces( milkObjects, cheeseObjects )

def generate_scenario(fileName):
    read_api_password()
    scenarioFile = open (fileName, 'r' )
    scenario = json.loads( scenarioFile.read() )
    folderName = scenario["scenarioName"]
    
    for productName in scenario["productsInOrder"]:
        product_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)),'scenario', folderName, 'products',productName)
        productFiles = [f for f in os.listdir('./scenario/' + folderName + '/' + 'products' + '/' + productName )]
        print(productFiles)
        for prodFileName in productFiles:
            createObjectFromJSONFile ( os.path.join(product_dir , prodFileName.encode('utf-8')) )
    relations_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)),'scenario', folderName, 'relations')
    relationFiles = [f for f in os.listdir(relations_dir)]
    print(relationFiles)
    for relFileName in relationFiles:
        createRelationFromJSONFile( relFileName.encode('utf-8') )
    scenarioFile.close()

def createObjectFromJSONFile (objFileName):
    with open (objFileName) as objectFile:
        payload = json.loads( objectFile.read() )
        print(json.dumps(payload))
    api_postasadmin_with_method( 'createObject', json.dumps(payload) )
    #objectFile.close()

def createRelationFromJSONFile (relFileName):
    relationFile = open (relFileName, 'r')
    payload = json.loads( relationFile.read() )
    api_postasadmin_with_method( 'addPredecessor', json.dumps(payload) )
    relationFile.close()

def read_api_password():
    global apiPassword
    apiPassword = getpass.getpass("Please enter the admin password for the REST API: ")

def init_demo_attributes():
    files = [f for f in os.listdir('.') if os.path.isfile(f) and "attribute" in f]
    print(files)
    for fileName in files:
        partString = fileName.split("_")
        print (partString)
        attributeFile = open (fileName, 'r' )
        payload = json.loads( attributeFile.read() )
        print (json.dumps(payload))
        api_postasadmin_with_method ( 'META_addAttributeDefinition' , json.dumps(payload) )
        attributeFile.close()

def init_demo_units():
    files = [f for f in os.listdir('.') if os.path.isfile(f) and "unit" in f]
    print(files)
    for fileName in files:
        unitFile = open (fileName, 'r' )
        payload = json.loads( unitFile.read() )
        print ( json.dumps(payload) )
        api_postasadmin_with_method ( 'META_addUnit' , json.dumps(payload) )
        unitFile.close()

def init_demo_objects():
    files = [f for f in os.listdir('.') if os.path.isfile(f) and "object" in f]
    print(files)
    for fileName in files:
        objectFile = open (fileName, 'r' )
        payload = json.loads( objectFile.read() )
        print (json.dumps(payload))
        api_postasadmin_with_method ( 'META_addProductDefinition' , json.dumps(payload) )
        objectFile.close()

def generate_demo_objects( objectName , templateFileName, atIntervalSeconds = 0):
    generatedObjectList = []
    fileProductTemplate = open (templateFileName, "r") 
    #   Reading from file 
    data = json.loads(fileProductTemplate.read()) 

    # Generating new id
    objectCount = input("Please enter the number of basic " + objectName + " to create: ")
    for i in range( 1, objectCount + 1) :
        data['id'] = str.upper(objectName) + str(i)
        data['amount'] = random.randint(50,200)
        data['attrValues'] = [ str(random.randint(80,100)) ]
        # Serializing json  
        json_object = json.dumps(data, indent = 2) 
        print(json_object)
        save_object(data, objectName + str(i) + '.json')
        api_postasadmin_with_method( 'createObject', json_object )
        # What if the target object already exists?
        generatedObjectList.append( data )
        time.sleep( atIntervalSeconds )
    # Closing file 
    fileProductTemplate.close() 
    return generatedObjectList

# WARNING: If you create a large number of objects with large amounts, it may take above O(n^2) time to generate them with this method so beware :)
# A way of improving the method would be to "cut" the already maximally generated target objects off a list and not pick any random target
def generate_object_links_produces( fromObjects, toObjects):
    fileRelationTemplate = open ('addpredecessor_relation_template.json', "r") 
    data = json.loads( fileRelationTemplate.read() ) 
    # Remember that these are finite quantities, so we produce as much as possible from the left side to the right side
    # This is a very simplistic approach, can be extended by taking real proportions into consideration
    # We assume a 10:1 proportion from left units to right units
    LEFT_PROPORTION = 10
    RIGHT_PROPORTION = 1
    MAX_TARGET_PRODUCED_QUANTITY = 250
    
    print(fromObjects)
    print(toObjects)
    for sourceProduct in fromObjects:
        if sourceProduct['amount'] > 0 and sourceProduct['amount'] > LEFT_PROPORTION:
            #Select random target object in toObjects
            while True:
              toElementIndex = random.randint(0, len( toObjects )-1)
              if toObjects[toElementIndex]['amount'] < MAX_TARGET_PRODUCED_QUANTITY:
                  print('Target index ' + str(toElementIndex))
                  break
            data['preIds'] = sourceProduct['id']
            data['id'] = toObjects[toElementIndex]['id']
            numberOfTargetUnitsToCreate = sourceProduct['amount'] // LEFT_PROPORTION
            data['amountDif'] = -( numberOfTargetUnitsToCreate * LEFT_PROPORTION ) 
            toObjects[toElementIndex]['amount'] += numberOfTargetUnitsToCreate
            json_object = json.dumps(data, indent = 2)
            print(json_object)
            api_postasadmin_with_method( 'addPredecessor' , json_object)
        if sourceProduct['amount'] > 0 and sourceProduct['amount'] < LEFT_PROPORTION:
            #We need a second product. This case is here for reference, not yet implemented.
            #It may also happen that we cannot get as much as LEFT_PROPORTION with 2 products, so we need a third and so on...
            print ('Amount too low, skipping production from this source: ' + sourceProduct['id'])
    fileRelationTemplate.close() 

def generate_random_deliveries ( fromObjects, toOrganizations):
    fileRelationTemplate = open ('setreceiver_relation_template.json', "r") 
    data = json.loads( fileRelationTemplate.read() ) 
    sourceObjectsList = fromObjects
    for sourceProduct in sourceObjectsList:
        data['id'] = sourceProduct['id']
        data['receiver'] = assign_random_target_orga()
        json_object = json.dumps(data, indent = 2)
        api_postasadmin_with_method( 'setReceiver' , json_object)
    fileRelationTemplate.close()

def assign_random_target_orga ():
    return random.choice( ORGANIZATIONS_LIST )

def api_postasadmin_with_method(methodname, payload):
    API_ENDPOINT = 'http://137.193.65.47:8080/submit?function=' + methodname
    #token_response = get_auth_token()
    #if token_response:
    #    currentToken = token_response 
    global currentToken
    headers = {
    'Authorization': 'Bearer ' + currentToken,
    'Content-Type': 'application/json',
    'Cookie': 'JSESSIONID=C7CD65AFB9E312D4CFD2AD9ABE9F7A10'
    }
    r = requests.post( url = API_ENDPOINT, data = payload, headers = headers, timeout = SECONDS_TO_WAIT_FOR_HTTP_REQUESTS) 
    if r.status_code == requests.codes.unauthorized | r.status_code == requests.codes.forbidden:
        print('Renewing token...')
        token_response = get_auth_token()
        if token_response:
            currentToken = token_response
            headers = {
                'Authorization': 'Bearer ' + currentToken,
                'Content-Type': 'application/json',
                'Cookie': 'JSESSIONID=C7CD65AFB9E312D4CFD2AD9ABE9F7A10'
            }
            try:
                r  = requests.post( url = API_ENDPOINT, data = payload, headers = headers, timeout = SECONDS_TO_WAIT_FOR_HTTP_REQUESTS)
            except:
                print("Request errored, status code: " + str(r.status_code))
    else:
        print("Request errored, status code: " + str(r.status_code))   

def get_auth_token():
    API_ENDPOINT = 'http://137.193.65.47:8080/auth'
    if (apiPassword.count < 1):
        print("Aborting, password empty or too short...")
        return False
    # data to be sent to api 
    data = {'username':'admin', 
            'password':apiPassword
           }  
    # sending post request and saving response as response object 
    r = requests.post(url = API_ENDPOINT, data = json.dumps(data), timeout = SECONDS_TO_WAIT_FOR_HTTP_REQUESTS) 
    if r.status_code == requests.codes.ok:
      return r.json()['token']
    else:
        print(r.status_code)
        return False
   
menu = ConsoleMenu("Demo data generator for NutriSafe V0.2", "Please select type of generation")

initialization_item = FunctionItem("Initialize data model", init_demo_datastructures)
scenario_based_item = FunctionItem("Scenario-based: Soft Cheese", generate_scenario, ["scenarioCheese.json"])
random_based_item = FunctionItem("Random generation of objects", generate_random_objects)
menu.append_item(initialization_item)
menu.append_item(scenario_based_item)
menu.append_item(random_based_item)

menu.show()







