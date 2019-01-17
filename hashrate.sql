WITH block_rows AS (
  SELECT *, ROW_NUMBER() OVER (ORDER BY timestamp) AS rn
  FROM `crypto-etl-ethereum-dev.ethereum_classic_blockchain.blocks`
)
SELECT mp.timestamp as block_time, 
TIMESTAMP_DIFF(mp.timestamp, mc.timestamp, SECOND) as time_elapsed,
((mp.difficulty + mc.difficulty) / 2) as average_difficulty,
((mp.difficulty + mc.difficulty) / 2) / TIMESTAMP_DIFF(mp.timestamp, mc.timestamp, SECOND) as hashrate
FROM block_rows mc
JOIN block_rows mp
ON  mc.rn = mp.rn - 1
ORDER BY block_time asc
