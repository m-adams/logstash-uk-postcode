# logstash-uk-postcode
Downloads and generates the files to to able to enrich UK postcodes with lat long locations when processing documents in logstash

Run create-logstash-dict.sh
beware it will need to download aprox 800MB file 

It downloads the open data and stripts the required info in to a smimple csv for use in logstash translate filter.
It then creats a sample logstash config, downloads logstash and sends a testfile to check the filter is working.

This should leave you with a working logstash config and you just need to change imput and output sections.

