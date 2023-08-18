#!/bin/bash

set -euo pipefail

mkdir -p ../datagen-graphs-regen

export ZSTD_NBTHREADS=`nproc`
export ZSTD_CLEVEL=12
export NUM_UPDATE_PARTITIONS=1


for SF in 0.1 0.3 1 3 10 30 100 300 1000; do
    echo SF: ${SF}

    # <turtle>
    SERIALIZER=Turtle

    # create configuration file
    echo > params.ini
    echo ldbc.snb.datagen.generator.scaleFactor:snb.interactive.${SF} >> params.ini
    echo ldbc.snb.datagen.serializer.dynamicActivitySerializer:ldbc.snb.datagen.serializer.snb.turtle.${SERIALIZER}DynamicActivitySerializer >> params.ini
    echo ldbc.snb.datagen.serializer.dynamicPersonSerializer:ldbc.snb.datagen.serializer.snb.turtle.${SERIALIZER}DynamicPersonSerializer >> params.ini
    echo ldbc.snb.datagen.serializer.staticSerializer:ldbc.snb.datagen.serializer.snb.turtle.${SERIALIZER}StaticSerializer >> params.ini
    echo ldbc.snb.datagen.serializer.numUpdatePartitions:${NUM_UPDATE_PARTITIONS} >> params.ini
    echo ldbc.snb.datagen.parametergenerator.parameters:false >> params.ini

    # run datagen
    ./run.sh

    # move the output to a separate directory
    mv social_network ../datagen-graphs-regen/social_network-sf${SF}-${SERIALIZER}
    mv params.ini ../datagen-graphs-regen/social_network-sf${SF}-${SERIALIZER}

    # compress the result directory using zstd
    cd ../datagen-graphs-regen
    tar --zstd -cvf social_network-sf${SF}-${SERIALIZER}.tar.zst social_network-sf${SF}-${SERIALIZER}/

    # cleanup
    rm -rf social_network-sf${SF}-${SERIALIZER}/

    # return and continue
    cd ../ldbc_snb_datagen_hadoop/
    rm -rf hadoop/
    # </turtle>

    for SERIALIZER in CsvBasic CsvComposite CsvCompositeMergeForeign CsvMergeForeign; do
        echo SERIALIZER: ${SERIALIZER}
            
        for DATEFORMATTER in StringDateFormatter LongDateFormatter; do
            echo DATEFORMATTER: ${DATEFORMATTER}

            # create configuration file
            echo > params.ini
            echo ldbc.snb.datagen.generator.scaleFactor:snb.interactive.${SF} >> params.ini
            echo ldbc.snb.datagen.serializer.dynamicActivitySerializer:ldbc.snb.datagen.serializer.snb.csv.dynamicserializer.activity.${SERIALIZER}DynamicActivitySerializer >> params.ini
            echo ldbc.snb.datagen.serializer.dynamicPersonSerializer:ldbc.snb.datagen.serializer.snb.csv.dynamicserializer.person.${SERIALIZER}DynamicPersonSerializer >> params.ini
            echo ldbc.snb.datagen.serializer.staticSerializer:ldbc.snb.datagen.serializer.snb.csv.staticserializer.${SERIALIZER}StaticSerializer >> params.ini
            echo ldbc.snb.datagen.serializer.dateFormatter:ldbc.snb.datagen.util.formatter.${DATEFORMATTER} >> params.ini
            echo ldbc.snb.datagen.serializer.numUpdatePartitions:${NUM_UPDATE_PARTITIONS} >> params.ini
            echo ldbc.snb.datagen.parametergenerator.parameters:false >> params.ini

            # run datagen
            ./run.sh

            # move the output to a separate directory
            mv social_network ../datagen-graphs-regen/social_network-sf${SF}-${SERIALIZER}-${DATEFORMATTER}
            mv params.ini ../datagen-graphs-regen/social_network-sf${SF}-${SERIALIZER}-${DATEFORMATTER}

            # compress the result directory using zstd
            cd ../datagen-graphs-regen
            tar --zstd -cvf social_network-sf${SF}-${SERIALIZER}-${DATEFORMATTER}.tar.zst social_network-sf${SF}-${SERIALIZER}-${DATEFORMATTER}/

            # cleanup
            rm -rf social_network-sf${SF}-${SERIALIZER}-${DATEFORMATTER}/

            # return and continue
            cd ../ldbc_snb_datagen_hadoop/
            rm -rf hadoop/
        done
    done
done
