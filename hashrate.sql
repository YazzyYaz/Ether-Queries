WITH block_rows AS (
  SELECT *, ROW_NUMBER() OVER (ORDER BY timestamp) AS rn 
  FROM `bigquery-public-data.ethereum_blockchain.blocks`
)
SELECT TIMESTAMP_DIFF(mp.timestamp, mc.timestamp, SECOND)
FROM block_rows mc
JOIN block_rows mp
ON  mc.rn = mp.rn - 1
