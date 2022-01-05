# Cosmos Graph Demo

## Deploy infrastructre

- update `param.dev.json` file based on your requirements
  - change `clientIp` to your workstation ip ( Default value `0.0.0.0`)
  - change `sqlAdminPassword` to a strong password ( Default value `**ChangeMeNow1234!**`)
- run below command to create cosmosdb database and collection
  - `az login`
  - `az deployment sub create --location southeastasia --template-file infra/main.bicep --parameters infra/params.dev.json`
- Below services will be deployed
  - Azure Cosmos DB
  - Azure Search
  - Synapse Workspace with default storage account and Spark medium pool

## Load data

Data source: [Kaggle Fraud Transaction Detection](https://www.kaggle.com/llabhishekll/fraud-transaction-detection/data). A copy of this data is available in this repo at [PS_20174392719_1491204439457_log.csv](load_data/data/PS_20174392719_1491204439457_log.csv) ( NOTE: you need to use [git-lfs](https://git-lfs.github.com/) to download the csv file locally )

### PySpark

- Create Synapse spark medium pool in Synpase. [Link](https://docs.microsoft.com/en-us/azure/synapse-analytics/quickstart-create-apache-spark-pool-portal)
- Upload csv file into Synapse linked storagae account
- create linked service to mount the storage account e.g. `linked-storage-service`
- Import notebook ["`insert_transact_data_spark.ipynb`"](load_data/insert_transact_data_spark.ipynb)
- Update `linkedService` , `cosmosEndpoint`, `cosmosMasterKey`, `cosmosDatabaseName` and `cosmosContainerName` in notebook
- run notebook

## Query data

### Why Graph and not SQL?

Graph helps solve **complex** problems by utilizing power of **relationships** between objects, eventhough some of these can be modeled as SQL statements gremlin api provide a more concise way to express and search relationships

- [Sample Queries](sample_queries.md)

### Why use Azure search

Cosmos is great for running OLTP queries and if you need to search for data within edges/transactions, Azure search is a great option.

## Visualization

- CosmosDB visulaization solutions are available in [Graph Visualization Partners](https://docs.microsoft.com/en-us/azure/cosmos-db/graph/graph-visualization-partners)
- Sample dashboard app based on [streamlit](https://github.com/streamlit/streamlit) is available [here](visualize/dashboard.py)

  - To run the app

    - Install dependencies from [requirements.txt](./requirements.txt)
    - create `.env` files with

      - `COSMOS_DATABASE`, `COSMOS_GRAPH_COLLECTION`, `COSMOS_KEY` and `COSMOS_ENDPOINT` from Cosmos DB account
      - `SEARCH_KEY`, `SEARCH_INDEX` and `SEARCH_ENDPOINT` from Search service
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

    - run `streamlit run visualize/dashboard.py`
    - screenshot of [dashboard](images/dashboard.png)

## Azure Search (Optional used for dashboard and enable search queries)

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

## References

- <https://tinkerpop.apache.org/docs/current/tutorials/getting-started/>
- <https://tinkerpop.apache.org/docs/current/reference/#a-note-on-lambdas>
- <https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/cosmos-db/graph/gremlin-limits.md>

## License

MIT

---

> GitHub [@lordlinus](https://github.com/lordlinus) &nbsp;&middot;&nbsp;
> Twitter [@lordlinus](https://twitter.com/lordlinus) &nbsp;&middot;&nbsp;
> Linkedin [Sunil Sattiraju](https://www.linkedin.com/in/sunilsattiraju/)
