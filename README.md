# SmartOS zoneinit

Basic service to finalize a new SmartOS zone provisioned.

## zoneinit

The zoneinit script runs under SMF and finalizes a new zone just provisioned.
Once it concludes with a non-zero status, it won't run again. If it fails for
whatever reason, the entire zone provision is evaluated as a failure.

## includes

Holds all the current zoneinit include scripts. They get executed in numeral
order.

## mdata-fetch / mdata-execute

The mdata-fetch and mdata-execute scripts are provided for when they do not
exist yet in the OS (as is the case of e.g. most compute nodes in JPC). They
only divert slightly from their current OS variants, to address differencies
on legacy platforms. The accompanying mdata.xml manifest defines the 'mdata'
SMF service.
