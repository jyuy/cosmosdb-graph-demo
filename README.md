# Cosmos Graph Demo

## Problem statement

Bank transactions have traditionally been stored in transactional databases and analysed using SQL queries and to increase scale they are now analysed in distributed systems using Apache Spark. While SQL is great to analyse this data finding relationships between transactions and accounts can be challenging. In this scenario we want to visualize 2 level of customer relationships i.e. if A sends to B and B send to C then we want to identify C when we look at transactions made by A together with C and vice versa.

## Why does this solution solve the problem

Graph helps solve **complex** problems by utilizing power of **relationships** between objects, some of these can be modeled as SQL statements but gremlin api provide a more concise way to express and search relationships. In this solution we are using Azure Cosmos Graph DB to store transactions data with customer account id as vertices and transaction as edges and transactional amount as properties of the edges.Since running fan out queries on Cosmos DB is not ideal we are leveraging Azure cognitive search to index data in Cosmos DB and leverage search api perform full scan/search queries. Additionally, Azure search will give us the flexibility to search for account either received or sent. This provides a scalable solution that can scale for any number of transactions and keeping the RU requirement for Cosmos queries low.

## Getting started

### Deploy infrastructure

Option 1. Click on below link to deploy the template.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Flordlinus%2Fcosmosdb-graph-demo%2Fmain%2Finfra%2Fmain.json)

Option 2. Clone this repository to your local machine and navigate to `infra` folder. Bicep code is included with this repository and will deploy Cosmos DB, Synapse Spark pool and Azure Search service and follow the below steps

   1. update `param.dev.json` file based on your requirements
   2. change `clientIp` to your workstation ip ( Default value `0.0.0.0`)
   3. change `sqlAdminPassword` to a strong password ( Default value `**ChangeMeNow1234!**`)
   4. run below command to create cosmosdb database and collection, Azure Search service and Synapse spark pool

   ```bash
   az login
   az deployment sub create --location southeastasia --template-file infra/main.bicep --parameters infra/params.dev.json
   ```

Option 3. Use GiHub actions to deploy services. Go to [github_action_infra_deployment](github_action_infra_deployment.md) to see how to deploy services.

### Load data

Data source: [Kaggle Fraud Transaction Detection](https://www.kaggle.com/llabhishekll/fraud-transaction-detection/data). A copy of this data is available in this repo at [PS_20174392719_1491204439457_log.csv](load_data/data/PS_20174392719_1491204439457_log.csv) ( NOTE: you need to use [git-lfs](https://git-lfs.github.com/) to download the csv file locally )

### Data ingestion using PySpark

- Upload csv file into Synapse linked storage account
- create linked service to mount the storage account e.g. `linked-storage-service`
- Import notebook ["`insert_transact_data_spark.ipynb`"](load_data/insert_transact_data_spark.ipynb)
- Update `linkedService` , `cosmosEndpoint`, `cosmosMasterKey`, `cosmosDatabaseName` and `cosmosContainerName` in notebook
- run notebook and monitor the progress of data load from Cosmos DB insights view ( NOTE: Cosmos billing is per hour so adjust your RU's accordingly to minimize cost)

### Azure search Cosmos index creation

- Cosmos DB Gremlin data is stored in json and available using SQL api as well, follow this [reference](https://docs.microsoft.com/en-us/azure/search/search-howto-index-cosmosdb) on how to create index on Cosmos DB Gremlin data
- Sample [Gremlin Queries](sample_queries.md) you can execute from the Cosmos DB Azure portal

### Azure Search Cosmos Index and Indexer creation using API

Refer to [Azure Search Cosmos Index and Indexer](https://docs.microsoft.com/en-us/azure/search/search-howto-index-cosmosdb) for more details on how to create index and indexer for cosmos db graph data.

Below are API endpoint and payload for reference

<details>
<summary>Create CosmosDb Datasource</summary>

Endpoint: `{{baseUrl}}/datasources?api-version={{apiVersion}}`

```json
{
  "name": "transactions",
  "description": "Cosmos DB for transactions",
  "type": "cosmosdb",
  "subtype": "Gremlin",
  "credentials": {
    "connectionString": "AccountEndpoint=..........ApiKind=Gremlin;"
  },
  "container": {
    "name": "graph01",
    "query": "g.E()"
  }
}
```

</details>

<details>
<summary>Create Index</summary>

Endpoint: `{{baseUrl}}/indexes?api-version={{apiVersion}}`

```json
{
  "name": "cosmosdb-index",
  "fields": [
    {
      "name": "type",
      "type": "Edm.String",
      "facetable": false,
      "filterable": true,
      "key": false,
      "retrievable": true,
      "searchable": true,
      "sortable": false,
      "analyzer": "standard.lucene",
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "synonymMaps": [],
      "fields": []
    },
    {
      "name": "sink",
      "type": "Edm.String",
      "key": false,
      "facetable": false,
      "filterable": true,
      "retrievable": true,
      "searchable": true,
      "sortable": false,
      "analyzer": "standard.lucene",
      "synonymMaps": [],
      "fields": []
    },
    {
      "name": "sinkLabel",
      "type": "Edm.String",
      "key": false,
      "facetable": false,
      "filterable": false,
      "retrievable": true,
      "searchable": false,
      "sortable": false,
      "analyzer": null,
      "synonymMaps": [],
      "fields": []
    },
    {
      "name": "vertexId",
      "type": "Edm.String",
      "key": false,
      "facetable": false,
      "filterable": true,
      "retrievable": true,
      "searchable": true,
      "sortable": false,
      "analyzer": "standard.lucene",
      "synonymMaps": [],
      "fields": []
    },
    {
      "name": "vertexLabel",
      "type": "Edm.String",
      "key": false,
      "facetable": false,
      "filterable": false,
      "retrievable": true,
      "searchable": false,
      "sortable": false,
      "analyzer": null,
      "synonymMaps": [],
      "fields": []
    },
    {
      "name": "amount",
      "type": "Edm.Double",
      "facetable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": true,
      "analyzer": null,
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "synonymMaps": [],
      "fields": []
    },
    {
      "name": "oldbalanceOrg",
      "type": "Edm.Double",
      "facetable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": true,
      "analyzer": null,
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "synonymMaps": [],
      "fields": []
    },
    {
      "name": "oldbalanceDest",
      "type": "Edm.Double",
      "facetable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": true,
      "analyzer": null,
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "synonymMaps": [],
      "fields": []
    },
    {
      "name": "newbalanceDest",
      "type": "Edm.Double",
      "facetable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": true,
      "analyzer": null,
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "synonymMaps": [],
      "fields": []
    },
    {
      "name": "rid",
      "type": "Edm.String",
      "facetable": false,
      "filterable": false,
      "key": true,
      "retrievable": true,
      "searchable": false,
      "sortable": false,
      "analyzer": null,
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "synonymMaps": [],
      "fields": []
    }
  ]
}
```

</details>

<details>
<summary>Create Indexer with field mapping</summary>

Endpoint: `{{baseUrl}}/indexers?api-version={{apiVersion}}`

```json
{
  "name": "cosmosdb-indexer",
  "description": "",
  "dataSourceName": "transactions",
  "targetIndexName": "cosmosdb-index",
  "schedule": null,
  "parameters": {
    "maxFailedItems": 0,
    "maxFailedItemsPerBatch": 0,
    "base64EncodeKeys": false,
    "configuration": {}
  },
  "fieldMappings": [
    {
      "sourceFieldName": "_sink",
      "targetFieldName": "sink"
    },
    {
      "sourceFieldName": "_sinkLabel",
      "targetFieldName": "sinkLabel"
    },
    {
      "sourceFieldName": "_vertexId",
      "targetFieldName": "vertexId"
    },
    {
      "sourceFieldName": "_vertexLabel",
      "targetFieldName": "vertexLabel"
    }
  ],
  "outputFieldMappings": []
}
```

</details>

### Visualization

CosmosDB visualization solutions are available in [Graph Visualization Partners](https://docs.microsoft.com/en-us/azure/cosmos-db/graph/graph-visualization-partners)

- Sample dashboard app based on [streamlit](https://github.com/streamlit/streamlit) is available [here](visualize/dashboard.py)

  1. To run the app locally on your machine

     1. Install dependencies from [requirements.txt](./requirements.txt)
     2. create `.env` files with

        1. `COSMOS_DATABASE`, `COSMOS_GRAPH_COLLECTION`, `COSMOS_KEY` and `COSMOS_ENDPOINT` from Cosmos DB account
        2. `SEARCH_KEY`, `SEARCH_INDEX` and `SEARCH_ENDPOINT` from Search service
           <details>
           <summary>.env file example (replace with values from your services)</summary>

           ```bash
           COSMOS_DATABASE=database01
           COSMOS_GRAPH_COLLECTION=graph01
           COSMOS_KEY=xxxxx
           COSMOS_ENDPOINT=xxxxx.gremlin.cosmos.azure.com:443/
           SEARCH_KEY=xxxx
           SEARCH_INDEX=cosmosdb-index
           SEARCH_ENDPOINT=https://xxxxx.search.windows.net
           ```

           </details>

        3. run `streamlit run visualize/dashboard.py`
        4. screenshot of dashboard ![dashboard](images/dashboard_01.jpg)

  2. To run the app on Azure Container Instance and you can use GiHub actions to deploy services. Go to [github_action_dashboard_deployment](github_action_dashboard_deployment.md) to see how to deploy services.

  Note: you can build docker container from local machine

  ```bash
  ACR_NAME=<registry-name>
  az acr build --registry $ACR_NAME --image cosmosgraphdemo:v1 .
  ```

## Key highlights:

1. Synapse spark is used to bulk load data into gremlin using SQL api NOTE: Cosmos gremlin expects to have certain json fields in the edge properties. Since cosmos billing is charged per hour we need to adjust the RU's accordingly to minimize cost, a spark cluster with 4 nodes and cosmos throughput at 20,000 RU/s ( single region) both edges (9 Million ) and vertices (6 Million) records can be ingested in an hour.
2. All search fan-out queries are done using Azure cognitive search api, Cosmos indexer can be scheduled at regular intervals to update the index
3. To keep the RU's low, Gremlin query is constructed to include account list e.g. when you search for account `xyz` all account send or received from `xyz` is created as `vertices_list` and gremlin query to get 2 level of transactions is executed as `g.V().has('accountId',within({vertices_list})).optional(both().both()).bothE().as('e').inV().as('v').select('e', 'v')` you can customize this query based on your use-case

## Next steps

Clone/Fork this repo [cosmosdb-graph-demo](https://github.com/lordlinus/cosmosdb-graph-demo) update configurations and deploy in your own subscription. GitHub action to deploy [infra](github_action_infra_deploy.md) and [dashboard](github_action_dashboard_deployment.md) are provided for reference.

## References

- <https://tinkerpop.apache.org/docs/current/tutorials/getting-started/>
- <https://tinkerpop.apache.org/docs/current/reference/#a-note-on-lambdas>
- <https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/cosmos-db/graph/gremlin-limits.md>
- <https://github.com/LuisBosquez/azure-cosmos-db-graph-working-guides/blob/master/graph-backend-json.md>
- <https://syedhassaanahmed.github.io/2018/10/28/writing-apache-spark-graphframes-to-azure-cosmos-db.html>

## License

MIT

---

> GitHub [@lordlinus](https://github.com/lordlinus) &nbsp;&middot;&nbsp;
> Twitter [@lordlinus](https://twitter.com/lordlinus) &nbsp;&middot;&nbsp;
> Linkedin [Sunil Sattiraju](https://www.linkedin.com/in/sunilsattiraju/)
