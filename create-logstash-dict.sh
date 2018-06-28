#!/bin/bash
file="./National_Statistics_Postcode_Lookup_UK.csv"
url="https://opendata.camden.gov.uk/api/views/tr8t-gqz7/rows.csv?accessType=DOWNLOAD"
dictfile="./postcode-dictionary.csv"
logstashfolder="./logstash-6.3.0"
compression=".tar.gz"
configfile="./postcode.cgf"

if [ -f "$file" ]
then
	echo "source file: $file found."
else
	echo "source file: $file not found."
    echo "Downloading National Statistics postcode mapping file"
    curl --output $file $url
fi

if [ -f "$dictfile" ]
then
	echo "postcode dictionary file: $dictfile found."
else
	echo "postcode dictionary file: $file not found."
    echo "Processing source file to create dictionary"
    python ./filter_csv.py --input-file $file --output-file $dictfile
fi
if [ -f "$dictfile" ]
then
    if [ -d $logstashfolder ]
    then
        echo "logstash exists already"
    else
        echo "Can't find logstash folder $logstashfolder in local dir so downloading"
        curl -L -O https://artifacts.elastic.co/downloads/logstash/logstash-6.3.0.tar.gz
        tar -xzf $logstashfolder$compression
    fi
fi

echo "Testing config"
if [ -f "$configfile" ] 
then
    echo "Config file exists"

else
    echo "Creating config file"
    cat > $configfile << EOF
    input {
        stdin {
            id => "my_plugin_id"
        }
    }
    filter{
        json {
            source => "message"
        }
        mutate {
            uppercase => [ "postcode" ]
        }
        mutate {
            gsub => ["postcode", " ", ""]
        }
        translate {
        dictionary_path => "$dictfile"
        field => "postcode"
        destination => "[geo][location]"
        }
    }
    output {
        stdout { }
    }
EOF
fi

echo "Running logstash to test config with test file"
if echo '{"postcode":"sw1a 0aa"}' | ./$logstashfolder/bin/logstash -f $configfile | grep -q "51.49984,-0.124663"
then
echo "Congratulations! Tests pass, you have a working postcode enrichment"
else
echo "Something went wrong, I hope you like bash scripts"
echo "running logstash test again with output"
echo '{"postcode":"sw1a 0aa"}' | ./$logstashfolder/bin/logstash -f $configfile
fi