WITH avg_difficulty AS (
SELECT TIMESTAMP_TRUNC(timestamp, DAY) AS block_day,
AVG(difficulty) AS difficulty
FROM `crypto-etl-ethereum-dev.classic_blockchain.blocks`
GROUP BY TIMESTAMP_TRUNC(timestamp, DAY)
)
SELECT block_day, 
(difficulty / (24*60*60)) / EXP(9) AS hashrate
FROM avg_difficulty
ORDER BY block_day ASC
