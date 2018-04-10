# -*- coding: utf-8 -*-
"""
Created on Sun Mar 25 16:07:48 2018

@author: Griff
"""
from imdb import IMDb
import tmdbsimple as tmdb
import pandas as pd
import progressbar as prog
import os.path

##make iterator random later:
#random_list = random.sample(xrange(10000000), movie_count) 
def GetRawMovies(movie_count, items_requested):
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

def CrossWithIMDb(raw_movies, desired_attributes_IMDb):
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


#################
    ##SETUP
#################
print('Pandas version ' + pd.__version__)
print('tmdbsimple version ' + tmdb.__version__)

movie_count_req = 10000

tmdb.API_KEY = '43c26e89f50364998e6d406599d25aa5'
db = IMDb()


#################
    ##TMDb
#################    
TMDb_attributes = ['revenue','vote_average','vote_count'
                           ,'title','original_language','release_date'
                           ,'production_companies','production_countries','genres']

raw_movies = GetRawMovies(movie_count_req, TMDb_attributes)

if(raw_movies is not None):
    pd.DataFrame(data=raw_movies, columns = TMDb_attributes).to_csv('Movies.csv',index=False,header=True)


#################
    ##IMDb
#################
IMDb_attributes = ["director","producer","cast","runtimes","writer"]

raw_movies = pd.read_csv('Movies.csv')

raw_movies = CrossWithIMDb(raw_movies, IMDb_attributes)

pd.DataFrame(data=raw_movies, columns = TMDb_attributes+IMDb_attributes).to_csv('Movies.csv',index=False,header=True)

print(raw_movies)
#    print(movie['title'],movie['cast'][0],movie['cast'][1],movie['cast'][2])
        #print(item['long imdb canonical title'], item.movieID)


#db.search_movie("braveheart")
#raise ValueError('A very specific bad thing happened.')