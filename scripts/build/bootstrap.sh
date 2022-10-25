#! /bin/bash
 
# Copyright 2021 Google LLC
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# The following script will download the latest version of Nextflow.
# The script will then copy the updated config file and 
# create a service that will start automatically on reboot


# Check if the script has run before, if so exit
if [[ -f /etc/startup_was_launched ]]; then exit 0; fi


# Install Packages needed
apt-get update
apt-get install -y git wget openjdk-11-jdk


wget -qO- https://get.nextflow.io | bash
mkdir /usr/local/bin/nextflow
mv ./nextflow /usr/local/bin/nextflow

echo "export PATH=/usr/local/bin/nextflow:$PATH" >> /etc/profile
echo "export BUCKET=${BUCKET_URL}"

# Copy Config and Service files from Bucket
gsutil cp ${BUCKET_URL}/provisioning/nextflow.config /etc/nextflow.config

#Delete Config file as no longer needed on the bucket
chmod -R 777 /usr/local/bin/nextflow
chmod 777 /etc/nextflow.config
cat << EOF >> /etc/motd


░██████╗░░█████╗░░█████╗░░██████╗░██╗░░░░░███████╗  
██╔════╝░██╔══██╗██╔══██╗██╔════╝░██║░░░░░██╔════╝  
██║░░██╗░██║░░██║██║░░██║██║░░██╗░██║░░░░░█████╗░░  
██║░░╚██╗██║░░██║██║░░██║██║░░╚██╗██║░░░░░██╔══╝░░  
╚██████╔╝╚█████╔╝╚█████╔╝╚██████╔╝███████╗███████╗  
░╚═════╝░░╚════╝░░╚════╝░░╚═════╝░╚══════╝╚══════╝  

░█████╗░██╗░░░░░░█████╗░██╗░░░██╗██████╗░
██╔══██╗██║░░░░░██╔══██╗██║░░░██║██╔══██╗
██║░░╚═╝██║░░░░░██║░░██║██║░░░██║██║░░██║
██║░░██╗██║░░░░░██║░░██║██║░░░██║██║░░██║
╚█████╔╝███████╗╚█████╔╝╚██████╔╝██████╔╝
░╚════╝░╚══════╝░╚════╝░░╚═════╝░╚═════╝░

EOF

#Copy testdata to GCP
curl https://raw.githubusercontent.com/nf-core/test-datasets/imcyto/inputs/20191121_BRAC3438.6f.mcd |gsutil cp - ${BUCKET_URL}/data/inputs/20191121_BRAC3438.6f.mcd
curl https://raw.githubusercontent.com/nf-core/test-datasets/imcyto/inputs/metadata.csv |gsutil cp - ${BUCKET_URL}/data/inputs/metadata.csv
curl https://raw.githubusercontent.com/nf-core/test-datasets/imcyto/plugins/full_stack_preprocessing.cppipe |gsutil cp - ${BUCKET_URL}/data/plugins/full_stack_preprocessing.cppipe
curl https://raw.githubusercontent.com/nf-core/test-datasets/imcyto/plugins/ilastik_stack_preprocessing.cppipe |gsutil cp - ${BUCKET_URL}/data/plugins/ilastik_stack_preprocessing.cppipe
curl https://raw.githubusercontent.com/nf-core/test-datasets/imcyto/plugins/segmentation.cppipe |gsutil cp - ${BUCKET_URL}/data/plugins/segmentation.cppipe
curl https://raw.githubusercontent.com/nf-core/test-datasets/imcyto/plugins/ilastik_training_params.ilp |gsutil cp - ${BUCKET_URL}/data/plugins/ilastik_training_params.ilp

#Run only once
touch /etc/startup_was_launched
