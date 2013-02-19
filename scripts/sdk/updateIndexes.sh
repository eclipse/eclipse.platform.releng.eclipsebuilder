#!/usr/bin/env bash

# Utility to update both 3.x and 4.x index pages

source /shared/eclipse/sdk/updateIndexFilesFunction.shsource
updateIndex PDE
updateIndex CBI
