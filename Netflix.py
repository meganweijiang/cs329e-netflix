#!/usr/bin/env python3

# -------
# imports
# -------

from math import sqrt
import pickle
from requests import get
from os import path
from numpy import sqrt, square, mean, subtract

def create_cache(filename):
    """
    filename is the name of the cache file to load
    returns a dictionary after loading the file or pulling the file from the public_html page
    """
    cache = {}
    filePath = "/u/fares/public_html/netflix-caches/" + filename

    if path.isfile(filePath):
        with open(filePath, "rb") as f:
            cache = pickle.load(f)
    else:
        webAddress = "http://www.cs.utexas.edu/users/fares/netflix-caches/" + \
            filename
        bytes = get(webAddress).content
        cache = pickle.loads(bytes)

    return cache


AVERAGE_RATING = 3.60428996442
ACTUAL_CUSTOMER_RATING = create_cache(
    "cache-actualCustomerRating.pickle")
AVERAGE_MOVIE_RATING_PER_YEAR = create_cache(
    "cache-movieAverageByYear.pickle")
YEAR_OF_RATING = create_cache("cache-yearCustomerRatedMovie.pickle")
CUSTOMER_AVERAGE_RATING_YEARLY = create_cache(
    "cache-customerAverageRatingByYear.pickle")
AVG_CUSTOMER_RATING = create_cache("cache-averageCustomerRating.pickle")
AVG_MOVIE_RATING = create_cache("cache-averageMovieRating.pickle")


# ------------
# netflix_eval
# ------------

def netflix_eval(reader, writer) :
    predictions = []
    actual = []

    # iterate throught the file reader line by line
    for line in reader:
    # need to get rid of the '\n' by the end of the line
        line = line.strip()
        # check if the line ends with a ":", i.e., it's a movie title 
        if line[-1] == ':':
		# It's a movie
            current_movie = line.rstrip(':')
            if int(current_movie) in AVG_MOVIE_RATING:
                prediction = AVG_MOVIE_RATING[int(current_movie)]
            else:
                prediction = AVERAGE_RATING
            writer.write(line)
            writer.write('\n')
        else:
		# It's a customer
            current_customer = line
            if int(current_customer) in AVG_CUSTOMER_RATING and int(current_movie) not in AVG_MOVIE_RATING:
                prediction = AVG_CUSTOMER_RATING[int(current_customer)]
            else:
                prediction = (AVG_CUSTOMER_RATING[int(current_customer)] + AVG_MOVIE_RATING[int(current_movie)])/2
            predictions.append(prediction)
            actual.append(ACTUAL_CUSTOMER_RATING[int(current_customer),int(current_movie)])
            writer.write(str(prediction)) 
            writer.write('\n')	
    # calculate rmse for predications and actuals
    rmse = sqrt(mean(square(subtract(predictions, actual))))
    writer.write(str(rmse)[:4] + '\n')

