

#  ESPECIFICACIONES DE LAS MAQUINAS QUE SE VAN A CREAR
variable "vms" {
  type = list(map(string))
  description = "Maquinas virtuales"
  default = [ 
    {"name": "kubemaster", "ip": "10.0.1.10", "size": "Standard_D2_v3"}, # 8 GB,   2 CPU 
    {"name": "kubenode1",  "ip": "10.0.1.11", "size": "Standard_D1_v2"}, # 3.5 GB, 1 CPU 
    {"name": "kubenode2",  "ip": "10.0.1.12", "size": "Standard_D1_v2"},  # 3.5 GB, 1 CPU 
    {"name": "kubenfs",    "ip": "10.0.1.13", "size": "Standard_D1_v2"}  # 3.5 GB, 1 CPU 
  ]
}