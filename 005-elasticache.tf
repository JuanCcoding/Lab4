# Aqui Crearemos un Cluster de Memcached en ElastiCache, nos servira para cachear el contenido estatico de nuestro crm
# debera configurarse el plugins por la interfaz del wordpress para conseguir su correcta integración

resource "aws_elasticache_cluster" "memcached_cluster" {
  cluster_id           = "memcachedcluster"
  engine               = "memcached"
  node_type            = "cache.t4g.micro"  # Cambia el tipo de instancia según tus necesidades
  num_cache_nodes      = 2                 # Número de nodos en el clúster
  parameter_group_name = "default.memcached1.6"
  port                 = 11211
  az_mode = "cross-az"
  network_type = "ipv4"
  security_group_ids = [aws_security_group.SG_memcached.id]
  subnet_group_name = aws_elasticache_subnet_group.memcached_subnet_group.name
}

# Crear el grupo de subredes para el clúster de ElastiCache
resource "aws_elasticache_subnet_group" "memcached_subnet_group" {
  name       = "memcached-subnet-group"
  subnet_ids = [aws_subnet.private1.id,aws_subnet.private2.id] 
#s
  tags = {
    Name = "Memcached subnet group"
  }
}