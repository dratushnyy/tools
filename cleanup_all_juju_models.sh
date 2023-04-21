#!/bin/bash

# Get a list of all Juju models
models=$(juju models | grep -v '^Controller' | awk '{print $1}' | sed '/^$/d')

# Iterate over the models and remove them
for model in $models; do
  echo "Destroying model: $model"
  juju destroy-model -y "$model"
  echo "Model $model destroyed."
done

# Verify that all models have been removed
remaining_models=$(juju models | grep -v '^Controller' | awk '{print $1}' | sed '/^$/d')

if [[ -z $remaining_models ]]; then
  echo "All models have been successfully removed."
else
  echo "Some models could not be removed:"
  echo "$remaining_models"
fi

