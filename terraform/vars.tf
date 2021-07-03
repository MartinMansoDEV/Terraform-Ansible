

#  ESPECIFICACIONES DE LAS MAQUINAS QUE SE VAN A CREAR
variable "vms" {
  type = list(map(string))
  description = "Maquinas virtuales"
  default = [ 
    {"name": "master-nfs", "size": "Standard_D2_v3"}, # 8 GB, 2 CPU 
    {"name": "worker1",    "size": "Standard_D1_v2"}, # 3.5 GB, 1 CPU 
    {"name": "worker2",    "size": "Standard_D1_v2"}  # 3.5 GB, 1 CPU 
  ]
}