import json
from fast_pagerank import pagerank_power
from scipy import sparse
import pandas as pd
import numpy as np
from interact import fetch_edges

# Create a sparse transition matrix


fetch_edges()


sources = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
targets = [2, 3, 4, 5, 6, 7, 8, 9, 10, 1]
weights = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
personalization = np.array([0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0])

df = pd.DataFrame({'sources': sources, 'targets': targets, 'weights': weights})

# If an edge is duplicated, take the last one
df = df.drop_duplicates(subset=['sources', 'targets'], keep='last')

sources, targets, weights = df['sources'], df['targets'], df['weights']

M = sparse.coo_matrix((weights, (sources,targets)), shape=(11, 11))

# Convert to CSR format

M = M.tocsr()

# Call Fast PageRank

pr = pagerank_power(M, p=0.85, personalize=personalization)

print(pr)

event = {
    # 'node': 1,
    'top_n': 5,
    'return': 'graph'
}

# Sort the nodes by PageRank value. Create a new graph with the top N nodes and their edges.

results = pd.DataFrame({'node': np.arange(len(pr)), 'pagerank': pr})

results = results.sort_values(by='pagerank', ascending=False)

top_n = 5

top_results = results.iloc[:top_n]

truncated_df = df[df['sources'].isin(top_results['node']) & df['targets'].isin(top_results['node'])]



def lambda_handler(event, context):
    """If a node is given, return the pagerank of that node. Otherwise, return the pagerank of all nodes. """
    node = event['queryStringParameters'].get('node')
    if node:
        message = {'pagerank': pr[node]}
    else:
        message = {'nodes':top_results.to_dict(orient='list'),'edges' : truncated_df.to_dict(orient='list')}

    response = message#{'message': message}
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': response #json.dumps()
    }

if __name__ == '__main__':
    
    print(lambda_handler(event, None))
