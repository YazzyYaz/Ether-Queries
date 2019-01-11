with double_entry_book as (
  select to_address as address, value as value, block_timestamp
    -- debits
    from `bigquery-public-data.ethereum_blockchain.traces`
    where to_address is not null
    and status = 1
    and (call_type not in ('delegatecall', 'callcode', 'staticcall') or call_type is null)
    union all
    -- credits
    select from_address as address, -value as value, block_timestamp
    from `bigquery-public-data.ethereum_blockchain.traces`
    where from_address is not null
    and status = 1
    and (call_type not in ('delegatecall', 'callcode', 'staticcall') or call_type is null)
    union all
    -- transaction fees debits
    select miner as address, sum(cast(receipt_gas_used as numeric) * cast(gas_price as numeric)) as value, timestamp as block_timestamp
    from `bigquery-public-data.ethereum_blockchain.transactions` as transactions
    join `bigquery-public-data.ethereum_blockchain.blocks` as blocks on blocks.number = transactions.block_number and blocks.timestamp = transactions.block_timestamp
    group by blocks.miner, block_timestamp
    union all
    -- transaction fees credits
    select from_address as address, -(cast(receipt_gas_used as numeric) * cast(gas_price as numeric)) as value, block_timestamp
    from `bigquery-public-data.ethereum_blockchain.transactions`
),
double_entry_book_by_date as (
  select 
        date(block_timestamp) as date, 
        address, 
        sum(value * 0.00000001) as value
    from double_entry_book
    group by address, date
)
select * from double_entry_book_by_date limit 10;
