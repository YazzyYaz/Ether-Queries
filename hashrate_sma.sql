WITH block_rows AS (
  SELECT *, ROW_NUMBER() OVER (ORDER BY timestamp) AS rn
  FROM `crypto-etl-ethereum-dev.ethereum_classic_blockchain.blocks`
),
time_and_hash AS (
  SELECT
  mp.timestamp as block_time,
  TIMESTAMP_DIFF(mp.timestamp, mc.timestamp, SECOND) as delta_block_time,
  ((mp.difficulty + mc.difficulty) / 2) as average_difficulty,
  ((mp.difficulty + mc.difficulty) / 2) / TIMESTAMP_DIFF(mp.timestamp, mc.timestamp, SECOND) as hashrate,
  1 / TIMESTAMP_DIFF(mp.timestamp, mc.timestamp, SECOND) as block_frequency
  FROM block_rows mc
  JOIN block_rows mp
  ON mc.rn = mp.rn - 1
)
SELECT block_time, 
AVG(hashrate) OVER (ORDER BY block_time ASC ROWS 100 PRECEDING) AS sma_hashrate_100_blocks,
AVG(block_frequency) OVER (ORDER BY block_time ASC ROWS 100 PRECEDING) AS sma_frequency_100_blocks
FROM time_and_hash
ORDER BY block_time ASC
