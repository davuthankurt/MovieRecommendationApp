import pandas as pd
import json
import os
import sys


def get_recommendations(userInput):

    current_dir = os.path.dirname(os.path.abspath(__file__))


    csv_file_path = os.path.join(current_dir, 'tmdb_5000_movies.csv')

    moviesDf = pd.read_csv(csv_file_path)

    moviesDf['title'] = moviesDf['title'].apply(lambda x: x.strip())

    moviesDf['genres'] = moviesDf.genres.str.split('|')



    genre_names = set()
    moviesDf = moviesDf[["id","title","genres","release_date"]]
    moviesWithGenresDf = moviesDf.copy()

    holder = []
    names =[]
    for index, row in moviesDf.iterrows():
        for item in row['genres']:
            genres = json.loads(item)
            
            for genre in genres:

                genre_names.add(genre["name"])
                holder.append(genre["name"])
                
                moviesWithGenresDf.at[index, genre["name"]] = 1
            names.append("|".join(holder))
            holder.clear()
    moviesDf["genres"] = names

                                
    list(genre_names)


    moviesWithGenresDf = moviesWithGenresDf.fillna(0)

    moviesWithGenresDf["release_date"] = moviesWithGenresDf["release_date"].apply(lambda x : str(x).split("-")[0])

    
    inputMovies = pd.DataFrame(userInput)
    

    inputId = moviesDf[moviesDf['id'].isin(inputMovies['id'].tolist())]

    inputMovies = pd.merge(inputId, inputMovies)

    inputMovies = inputMovies.drop('genres',axis= 1).drop('release_date',axis= 1)

    userMovies = moviesWithGenresDf[moviesWithGenresDf['id'].isin(inputMovies['id'].tolist())]
 
    userMovies = userMovies.reset_index(drop=True)

    userGenreTable = userMovies.drop('id',axis= 1).drop('title',axis= 1).drop('genres',axis= 1).drop('release_date',axis= 1)



    inputMovies['rating']

    userProfile = userGenreTable.transpose().dot(inputMovies['rating'])

    genreTable = moviesWithGenresDf.set_index(moviesWithGenresDf['id'])

    genreTable = genreTable.drop('id',axis= 1).drop('title', axis=1).drop('genres',axis= 1).drop('release_date',axis= 1)


    recommendationTableDf = ((genreTable*userProfile).sum(axis=1))/(userProfile.sum())

    recommendationTableDf = recommendationTableDf.sort_values(ascending=False)



    moviesDf["release_date"] = moviesWithGenresDf["release_date"].apply(lambda x : str(x).split("-")[0])


    recommended_movies = moviesDf.loc[moviesDf['id'].isin(recommendationTableDf.head(20).keys())]

    ordered_recommended_movies = recommended_movies.set_index('id').reindex(recommendationTableDf.head(20).keys()).reset_index()
    ordered_recommended_movies = ordered_recommended_movies[["id"]]
    ordered_recommended_movies = ordered_recommended_movies.to_dict(orient='records')

    return ordered_recommended_movies

if __name__ == "__main__":
    userInput = json.loads(sys.argv[1])
    recommendations = get_recommendations(userInput)
    print(json.dumps(recommendations))