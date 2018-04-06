# -*- coding: utf-8 -*-
"""
Created on Sun Mar 25 16:07:48 2018

@author: Griff
"""
from imdb import IMDb
import tmdbsimple as tmdb
import pandas as pd
import progressbar as prog


tmdb.API_KEY = '43c26e89f50364998e6d406599d25aa5'
db = IMDb()

print('Pandas version ' + pd.__version__)
print('tmdbsimple version ' + tmdb.__version__)

def GetRawMovies():
    i,g = 1,0 #1 throws error on tmdb
    totalMoviesRequested = 10000
    raw_movies = list()
    items_requested = ['revenue','vote_average','vote_count','title','original_language','release_date','production_companies','production_countries','genres']
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
                    for i in range(count):
                        attribValue += raw_movie_data.get(key)[i]["name"] + ( "" if i == (count-1) else ",")
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

raw_movies = GetRawMovies()
print(len(raw_movies))

#db.search_movie("braveheart")
pd.DataFrame(data=raw_movies, columns = ['revenue',
                                         'vote_average',
                                         'vote_count',
                                         'title',
                                         'original_language',
                                         'release_date',
                                         'production_companies',
                                         'production_countries',
                                         'genres']).to_csv('Movies.csv',index=False,header=True)
