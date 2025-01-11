#!/bin/bash

mdbook build
rsync --progress -r -v book/* ecsypno@162.215.121.89:documentation.ecsypno.com/scnr/
