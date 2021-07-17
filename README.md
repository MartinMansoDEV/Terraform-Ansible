```
__________________________________________________________________________________
   ______                                          __  _               ___ 
  / ____/___ __________     ____  _________ ______/ /_(_)________     |__ \
 / /   / __ `/ ___/ __ \   / __ \/ ___/ __ `/ ___/ __/ / ___/ __ \    __/ /
/ /___/ /_/ (__  ) /_/ /  / /_/ / /  / /_/ / /__/ /_/ / /__/ /_/ /   / __/ 
\____/\__,_/____/\____/  / .___/_/   \__,_/\___/\__/_/\___/\____/   /____/ 
                        /_/                                                
                                                                by Martín Manso
__________________________________________________________________________________

```

A continuación detallaré como desplegar la infraestructura en Azure con Terraform y la instalación de Kubernetes e InfluxDB con Ansible, utilizando un servidor NFS común, ya que la aplicación será una aplicación balanceada.


1- TERRAFORM
===============

Para realizar este despliegue, vamos a desplegar **4 Servidores**.

Sistema operativo **CentOS 8**

```
├── Servidor Kubernetes [MASTER]         # 8GB RAM,   2 CPU 
|   |
│   ├── Servidor Kubernetes [Worker 1]   # 3.5GB RAM, 1 CPU
|   |
│   └── Servidor Kubernetes [Worker 2]   # 3.5GB RAM, 1 CPU
|   
├── Servidor NFS                         # 3.5GB RAM, 1 CPU
```

1.1 - Desplegar infraestructura
----------------------------

Lo primero que dememos hacer es crear crear el archivo credentials.tf en el directorio `./terraform`

Este archivo contiene nuestras credenciales con las que desplegar los recursos en Azure.

El contenido que debe de tener es el siguiente:

```
provider "azurerm" {
  features {}
  subscription_id = "<subscription_id>"
  client_id       = "<client_id>"
  client_secret   = "<client_secret>"
  tenant_id       = "<tenant_id>"
}
```


Una vez configuradas las credenciales, debemos modificar el archivo correction-vars.tf

ES IMPORTANTE QUE LA REGION SEA **West Europe** EN CUALQUIER OTRO CASO, VA A DAR ERROR.

Contenido del archivo correction-vars.tf:

```
variable "location" {
  type = string
  description = "Región de Azure donde crearemos la infraestructura"
  default = "West Europe"
}

variable "storage_account" {
  type = string
  description = "Nombre para la storage account"
  default = "storageaccountmanand"
}

variable "public_key_path" {
  type = string
  description = "Ruta para la clave pública de acceso a las instancias"
  default = "./id_rsa.pub" # o la ruta correspondiente
}

variable "ssh_user" {
  type = string
  description = "Usuario para hacer ssh"
  default = "uniruser"
}
```

Es imperativo que el archivo id_rsa.pub sea guardado en nuestro directorio .ssh ya que va a ser utilizado por ansible para desplegar el entorno.


Después de haber configurado estos dos archivos, si, es el momento de desplegar nuestra infraestructura.

Para ello introduciremos en nuestra terminal: `terraform  apply`

Una vez desplegados todos los recursos, nos mostrará un mensaje como el siguiente:

`Apply complete! Resources: 29 added, 0 changed, 0 destroyed.`

En azure nos ha generado 4 servidores con las siguientes DNS:

- kubemaster-manand.westeurope.cloudapp.azure.com
- kubenfs-manand.westeurope.cloudapp.azure.com
- kubenode1-manand.westeurope.cloudapp.azure.com
- kubenode2-manand.westeurope.cloudapp.azure.com

Estas direcciones DNS serán utilizadas para conectarse con **Ansible**


2- ANSIBLE
===============

Una vez montada la infraestructura, procederemos a instalar [Kubernetes](https://kubernetes.io) y la app de [InfluxDB](https://www.influxdata.com/) en nuestro cluster, para ello haremos uso del software de Ansible.


2.1 - Desplegar Kubernetes e InfluxDB
----------------------------


El primer paso es comprobar que todos los hosts que tenemos declarado en el archivo `./ansible/hosts` estén creados en la nube de Azure.

La estructura es la siguiente:

```
[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
ansible_user=uniruser

[master]
kubemaster-manand.westeurope.cloudapp.azure.com private_ip=10.0.1.10  ansible_host=kubemaster-manand.westeurope.cloudapp.azure.com

[workers]
kubenode1-manand.westeurope.cloudapp.azure.com private_ip=10.0.1.11 ansible_host=kubenode1-manand.westeurope.cloudapp.azure.com
kubenode2-manand.westeurope.cloudapp.azure.com private_ip=10.0.1.12 ansible_host=kubenode2-manand.westeurope.cloudapp.azure.com

[nfs]
kubenfs-manand.westeurope.cloudapp.azure.com private_ip=10.0.1.13 ansible_host=kubenfs-manand.westeurope.cloudapp.azure.com

```

Para comprobar que tenemos acceso a todos los nodos podemos ejecutar el siguiente comando desde el directorio `./ansible`:

`ansible -i hosts -m ping all`

Debemos tener una respuesta como esta:

```
kubenode1-manand.westeurope.cloudapp.azure.com | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
kubemaster-manand.westeurope.cloudapp.azure.com | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
kubenode2-manand.westeurope.cloudapp.azure.com | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
kubenfs-manand.westeurope.cloudapp.azure.com | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```

Una vez comprobado el estado de los servidores, es momento de desplegar Kubernetes y la aplicación.

Bastará con ejecutar el archivo deploy.sh dentro del directorio ansible.

`sh ./ansible/deploy.sh`


Cuando todo el proceso termine (le toma varios minutos ejecutar todo) nos mostrará en la terminal un mensaje como este:

```
TASK [deploy_app: URL Generada para acceder a la app balanceada] *************
ok: [kubemaster-manand.westeurope.cloudapp.azure.com] => {
   "msg": [
      "http://kubemaster-manand.westeurope.cloudapp.azure.com:30658"
   ]
}
```

Ya estaría desplegada la aplicación!!
