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


tmdb.API_KEY = '43c26e89f50364998e6d406599d25aa5'
db = IMDb()

print('Pandas version ' + pd.__version__)
print('tmdbsimple version ' + tmdb.__version__)

def GetRawMovies():
    if(not os.path.exists(os.path.dirname(os.path.realpath("Movies.csv")+"/Movies.csv"))):
        i,g = 1,0 #1 throws error on tmdb
        totalMoviesRequested = 10000
        raw_movies = list()
        items_requested = ['revenue','vote_average','vote_count'
                           ,'title','original_language','release_date'
                           ,'production_companies','production_countries','genres']
        keep_mining = True
        bar = prog.ProgressBar(max_value=totalMoviesRequested)
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
            if g >= totalMoviesRequested:
                keep_mining = False
        return raw_movies
    return None

raw_movies = GetRawMovies()

if(raw_movies is not None):
    pd.DataFrame(data=raw_movies, columns = ['revenue',
                                         'vote_average',
                                         'vote_count',
                                         'title',
                                         'original_language',
                                         'release_date',
                                         'production_companies',
                                         'production_countries',
                                         'genres']).to_csv('Movies.csv',index=False,header=True)

####cross with IMDb
#Get list of titles to search IMDb for
raw_movies = pd.read_csv('Movies.csv')
movieData = list()
desiredAttributes = ["director","producer","cast"]
for i in range(3    ):
    #Match title and year
    year = raw_movies['release_date'][i][:4]
    
    # Search for a movie (get a list of Movie objects).
    s_result = db.search_movie(raw_movies["title"][i])
    
    for item in s_result:
        if year in item['long imdb canonical title'] and item['kind'] is 'movie':
            db.update(item)
            movie = item
    
    dbData = list()
    for key in desiredAttributes:
        count = len(movie[key])
        attribValue = str("")
        for c in range(10 if count > 10 else count):
            attribValue += str(movie[key][c]) + ("" if c == (count-1) else ",")                        
        dbData.append(attribValue)
    
    movieData.append(dbData)
print(movieData)
#    print(movie['title'],movie['cast'][0],movie['cast'][1],movie['cast'][2])
        #print(item['long imdb canonical title'], item.movieID)


#db.search_movie("braveheart")
#raise ValueError('A very specific bad thing happened.')