#!/bin/bash

# Configurar todos los nodos (tareas comunes)
ansible-playbook -i hosts 01-configure_all_nodes.yaml 

# Configurar el servidor nfs
ansible-playbook -i hosts 02-configure_nfs.yaml

# Configurar el nodo master
ansible-playbook -i hosts 03-configure_master.yaml

# Configurar los nodos worker
ansible-playbook -i hosts 04-configure_workers.yaml 

# Desplegar la aplicacion
ansible-playbook -i hosts 05-deploy_app.yaml 