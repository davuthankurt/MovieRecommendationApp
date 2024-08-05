import pandas as pd
from math import sqrt
import json
import sys

def get_collaborative(userInput):

    moviesDf = pd.read_csv('tmdb_5000_movies.csv')

    ratingsDf = pd.read_csv('user_movie_data_with_ratings_longer.csv')


    moviesDf['title'] = moviesDf['title'].apply(lambda x: x.strip())


    moviesDf = moviesDf[["id","title"]]


    ratingsDf['userId'] = ratingsDf['userId'].astype(str)


    inputMovies = pd.DataFrame(userInput)


    inputId = moviesDf[moviesDf['id'].isin(inputMovies['id'].tolist())]

    inputMovies = pd.merge(inputId, inputMovies)


    subsetOfUsers = ratingsDf[ratingsDf['movieId'].isin(inputMovies['id'].tolist())]

    groupedUsers = subsetOfUsers.groupby('userId')

    groupedUsers = sorted(groupedUsers,  key=lambda x: len(x[1]), reverse=True)

    groupedUsers = groupedUsers[0:100]

    pearsonCorrelation = {}

    for name, group in groupedUsers:
        
        group = group.sort_values(by='movieId')
        inputMovies = inputMovies.sort_values(by='id')

        nRatings = len(group)
        

        tempDf = pd.concat([inputMovies[inputMovies['id'] == movieId] for movieId in group['movieId'].tolist()])
        

        ratingList = tempDf['rating'].tolist()   
        groupList = group['rating'].tolist()
       
        df = pd.DataFrame({'ratingList': ratingList, 'groupList': groupList})
        
        correlation_matrix = df.corr(method='pearson')
        pearson_correlation_value = correlation_matrix.loc['ratingList', 'groupList']
       
        pearsonCorrelation[name] = pearson_correlation_value if not pd.isna(pearson_correlation_value) else 0

    pearsonDF = pd.DataFrame.from_dict(pearsonCorrelation, orient='index')
    pearsonDF.columns = ['similarityIndex']
    pearsonDF['userId'] = pearsonDF.index
    pearsonDF.index = range(len(pearsonDF))


    topUsers=pearsonDF.sort_values(by='similarityIndex', ascending=False)[0:50]


    topUsersRating=topUsers.merge(ratingsDf, left_on='userId', right_on='userId', how='inner')


    topUsersRating['weightedRating'] = topUsersRating['similarityIndex']*topUsersRating['rating']


    tempTopUsersRating = topUsersRating.groupby('movieId').sum()[['similarityIndex','weightedRating']]
    tempTopUsersRating.columns = ['sum_similarityIndex','sum_weightedRating']


    recommendationDf = pd.DataFrame()

    recommendationDf['weighted average recommendation score'] = tempTopUsersRating['sum_weightedRating']/tempTopUsersRating['sum_similarityIndex']
    recommendationDf['movieId'] = tempTopUsersRating.index


    recommendationDf = recommendationDf.sort_values(by='weighted average recommendation score', ascending=False)

    last_output = moviesDf.loc[moviesDf['id'].isin(recommendationDf.head(10)['movieId'].tolist())]

    last_output = last_output[["id"]]
    last_output = last_output.to_dict(orient='records')
    return last_output




if __name__ == "__main__":
    userInput = json.loads(sys.argv[1])
    recommendations = get_collaborative(userInput)
    print(json.dumps(recommendations))
