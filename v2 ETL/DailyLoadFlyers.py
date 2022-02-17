#imports
import requests
import json
import csv
import pandas as pd
from pandas import json_normalize
from os.path import exists 

def pull_data(storename):
    #pull fresh API data
    request_url = 'https://backflipp.wishabi.com/flipp/items/search?locale=en-us&postal_code=98125&q=' + storename
    response_API = requests.get(request_url)
    data = response_API.text
    parse_json = json.loads(data)
    json_items = parse_json['items']
    df_new = json_normalize(json_items)
    df_new = df_new.drop(['score','item_weight','bottom','left','right','top'], axis = 1)
    df_new = df_new.dropna(subset=['current_price'])
    df_new.insert(0, 'Industry', 'Supermarket')
    #df_new.rename(columns={"name": "Product", "merchant_name": "Merchant"}) #placeholder in case I want to rename columns
    #print(df_new)
    #Only uncomment below to start a new file
    if exists('adhistory.xlsx') == 0:
        df_new.to_excel('adhistory.xlsx', index=False)
    #if exists('adhistory2.json') == 0:
    #    df_new.to_json('adhistory2.json')
    return df_new

def merge_data(filename, dataframe):
    #load offline data to dataframe
    df_old = pd.read_excel(filename + ".xlsx")
    #print(df_old)

    #append together (with concat?)
    df_combined = pd.concat([df_old, dataframe], axis=0)
    #df_combined.to_csv('datafile2combined.csv', index=False)
    #print(df_combined)

    #remove duplicates
    df_final = df_combined.drop_duplicates()
    #print(df_final)

    #how many rows were added?
    added_row_count = df_final.shape[0] - df_old.shape[0]

    #store back as original file
    df_final.to_excel(filename + ".xlsx", index=False)
    #df_final.to_json(filename + ".json")
    return added_row_count


#start main code
df = pull_data('FredMeyer')
print("FredMeyer added " + str(merge_data('adhistory', df)) + " rows")
df = pull_data('Walmart')
print("Walmart added " + str(merge_data('adhistory', df)) + " rows")
df = pull_data('QFC')
print("QFC added " + str(merge_data('adhistory', df)) + " rows")
df = pull_data('Safeway')
print("Safeway added " + str(merge_data('adhistory', df)) + " rows")
df = pull_data('Albertsons')
print("Albertsons added " + str(merge_data('adhistory', df)) + " rows")