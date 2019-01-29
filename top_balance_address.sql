#standardSQL
-- MIT License
-- Copyright (c) 2018 Evgeny Medvedev, evge.medvedev@gmail.com
with double_entry_book as (
    -- debits
    select to_address as address, value as value
    from `crypto-etl-ethereum-dev.classic_blockchain.traces`
    where to_address is not null
    and status = 1
    and (call_type not in ('delegatecall', 'callcode', 'staticcall') or call_type is null)
    union all
    -- credits
    select from_address as address, -value as value
    from `crypto-etl-ethereum-dev.classic_blockchain.traces`
    where from_address is not null
    and status = 1
    and (call_type not in ('delegatecall', 'callcode', 'staticcall') or call_type is null)
    union all
    -- transaction fees debits
    select miner as address, sum(cast(receipt_gas_used as numeric) * cast(gas_price as numeric)) as value
    from `crypto-etl-ethereum-dev.classic_blockchain.transactions` as transactions
    join `crypto-etl-ethereum-dev.classic_blockchain.blocks` as blocks on blocks.number = transactions.block_number
    group by blocks.miner
    union all
    -- transaction fees credits
    select from_address as address, -(cast(receipt_gas_used as numeric) * cast(gas_price as numeric)) as value
    from `crypto-etl-ethereum-dev.classic_blockchain.transactions`
)
select address, 
sum(value) / 1000000000 as balance
from double_entry_book
group by address
order by balance desc
limit 100000
