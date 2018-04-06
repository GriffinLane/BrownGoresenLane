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
        totalMoviesRequested = 5
        raw_movies = list()
        items_requested = ['revenue','vote_average','vote_count'
                           ,'title','original_language','release_date'
                           ,'production_companies','production_countries'
                           ,'genres']
        keep_mining = True
        bar = prog.ProgressBar(max_value=totalMoviesRequested)
        while(keep_mining):
            try:
                raw_movie_data = tmdb.Movies(i).info() 
                sifted_data = list()
                for key in items_requested:
                    if key in ['production_companies','production_countries','genres']:
                        count = len(raw_movie_data.get(key))
                        attribValue = str("")
                        for j in range(count):
                            attribValue += raw_movie_data.get(key)[j]["name"] + ( "" if j == (count-1) else ",")
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
#cross with IMDb


#db.search_movie("braveheart")
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
