
import MySQLdb
from MySQLdb import Connection
from sqlalchemy import create_engine
import pymysql
import os
import pandas as pd
import math

def get_raw_movies(movie_count, items_requested):
    print(os.path.dirname(os.path.realpath("Movies.csv")+"/Movies.csv"))
    if(not os.path.exists(os.path.dirname(os.path.realpath("Movies.csv")+"/Movies.csv"))):
        i,g = 1,0 #1 throws error on tmdb
        raw_movies = list()        
        keep_mining = True
        bar = prog.ProgressBar(max_value=movie_count)
        print("Getting TMDb Attributes")
        while(keep_mining):
            try:
                raw_movie_data = tmdb.Movies(i).info()
                if "False" not in str(raw_movie_data.get("adult")):
                    raise ValueError("we don't need to include adult films")
                sifted_data = list()
                for key in items_requested:                        
                    if key in ['production_companies','production_countries','genres']:
                        count = len(raw_movie_data.get(key))
                        attribValue = str("")
                        for j in range(count):
                            attribValue += raw_movie_data.get(key)[j]["name"] + ( "" if j == (count-1) else ",")                        
                        if key is "production_countries":
                            if "United States of America" not in attribValue:
                                raise ValueError("not made in America")
                        sifted_data.append(attribValue)
                    else:
                        sifted_data.append(raw_movie_data.get(key))
                raw_movies.append(sifted_data)
                g+=1
                i+=1
                bar.update(g)
            except:
                i+=1
                pass
            if g >= movie_count:
                keep_mining = False
        return raw_movies
    return None
    
def cross_with_IMDb(raw_movies, desired_attributes_IMDb):
    movie_count = len(raw_movies)
    bar = prog.ProgressBar(max_value=movie_count)
    print("Getting IMDb Attributes")
    for i in range(movie_count):
        #Match title and year
        year =  str(raw_movies['release_date'][i])[:4]
        
        #get a list of search results
        s_result = db.search_movie(raw_movies["title"][i])
        
        for item in s_result:
            if year in item['long imdb canonical title'] and item['kind'] is 'movie':
                db.update(item)
                movie = item
                
        for key in desired_attributes_IMDb:
            if key not in raw_movies:
                raw_movies[key] = [None] * movie_count
            if key not in movie.keys():
                raw_movies.loc[i,key] = None
                continue
            count = len(movie[key])
            attribValue = str("")
            for c in range(3 if count > 3 else count):
                attribValue += str(movie[key][c]) + ("" if c == (count-1) else ",")        
            raw_movies.loc[i,key] = attribValue        
        bar.update(i)
    return raw_movies

def split_string_columns(dataset, ignore_list):
    columns_with_strings = dataset.select_dtypes(include=object).columns
    columns_to_adjust = [elem for elem in columns_with_strings if (elem not in ignore_list)]
    for column in columns_to_adjust:
        dataset.loc[:,column] = dataset.loc[:,column].str.split(",")
    return dataset

def encode_columns(dataset):
    columns_with_strings = dataset.select_dtypes(include=object).columns
    for column in columns_with_strings:
        dataset[column].str.encode('latin-1', 'ignore')
    return dataset

def split_lists_to_columns(engine, dataset, columns, embed):
    from collections import Counter
    counts = Counter()    
    for column in columns:
        for item_list, ind in zip(dataset.loc[:,column],range(len(dataset[column]))):
            if(isinstance(item_list, float)):
                if(math.isnan(item_list)): continue                
            for item, i in zip(item_list, range(len(item_list))):
                if(item in ""): continue
                counts[item] += 1
                if (column+str(i+1) not in dataset):
                    dataset[column+str(i+1)] = pd.Series()
            for item, i in zip(item_list, range(len(item_list))):
                if(item in ""): continue
                if(column in embed):
                    dataset.loc[ind,column+str(i+1)] = counts[item]    
                else:
                    dataset.loc[ind,column+str(i+1)] = item
        test = pd.DataFrame.from_dict(counts, orient='index')
        test.columns = [column]
        create_table(test, column+"_frequency", engine)
        counts.clear()
    return dataset
global engine
def MySQL_login(host="localhost",user="root",passwd="root",db="project", ip="127.0.0.1:3306"):
    db = MySQLdb.connect(host,  # your host
                         user,       # username
                         passwd,     # password
                         db,    # name of the database
                        )   
    db.set_character_set('utf8')    
    # engine = create_engine('mysql+pymysql://{0}:{1}@{2}/{3}'.format(str(user),str(passwd),str(ip),str(db)), echo=False) 
    engine = create_engine('mysql+pymysql://root:root@127.0.0.1:3306/project', echo=False) #for now we will hardcode the local host ip
    return db,engine

#load default engine
def create_table(dataset, table_name, engine):
    dataset.to_csv("testEcodingFix.csv",index=False) #save a local copy for debugging
    dataset = pd.read_csv("testEcodingFix.csv", encoding="latin-1") #make sure it is viable with encoding
    dataset.to_sql(name=table_name, con=engine, if_exists = 'replace', index=False) 
    os.remove("testEcodingFix.csv")
    