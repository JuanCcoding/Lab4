#Aqui definimos las variables que decidimos usar, en mi caso fueron pocas, la mayoria apuntan a los tags para no
#colocarlos individualmente
# y la ami de nuestro lauch template que fue modificada varias veces


variable "ami_id" {
  type = string
  default = "ami-03647d532a7514a16"
}


variable "proyecto" {
type = string
default= "Laboratorio 4"
  
}

variable "env" {
  type = string
  default = "test"
}

variable "tagowner" {
  type = string
  default = "juan"
}
