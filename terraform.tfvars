public_subnets = {
  Public_Sub_WEB_1A = {
    name              = "Public_Sub_WEB_1A",
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-west-2a"
  },
  Public_Sub_WEB_1B = {
    name              = "Public_Sub_WEB_1B",
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-west-2b"
  },
}
private_subnets = {
  Private_Sub_APP_1A = {
    name              = "Private_Sub_APP_1A",
    cidr_block        = "10.0.3.0/24"
    availability_zone = "us-west-2a"
  },
  Private_Sub_APP_1B = {
    name              = "Private_Sub_APP_1B",
    cidr_block        = "10.0.4.0/24"
    availability_zone = "us-west-2b"
  },
  Private_Sub_DB_1A = {
    name              = "Private_Sub_DB_1A",
    cidr_block        = "10.0.5.0/24"
    availability_zone = "us-west-2a"
  },
  Private_Sub_DB_1B = {
    name              = "Private_Sub_DB_1B",
    cidr_block        = "10.0.6.0/24"
    availability_zone = "us-west-2b"
  }
}
nat-rta = {
  APP-1C = {
    route_table_id = "Public_Sub_WEB_1A",
    subnet_id      = "Private_Sub_APP_1A"

  },
  DB-1C = {
    route_table_id = "Public_Sub_WEB_1A",
    subnet_id      = "Private_Sub_DB_1A"

  },
  APP-1B = {
    route_table_id = "Public_Sub_WEB_1B",
    subnet_id      = "Private_Sub_APP_1B"
  },
  DB-1B = {
    route_table_id = "Public_Sub_WEB_1B",
    subnet_id      = "Private_Sub_DB_1B"

  },

}

iam_user = {
  sysadmin1 = {
    name = "sysadmin1"
    tags = { creator = "sysadmin1"
  } },
  sysadmin2 = {
    name = "sysadmin2"
    tags = { creator = "sysadmin2"
  } }
  monitor1 = {
    name = "monitor1"
    tags = { creator = "monitor1"
  } }
  monitor2 = {
    name = "monitor2"
    tags = { creator = "monitor2"
  } }
  monitor3 = {
    name = "monitor3"
    tags = { creator = "monitor3"
  } }
  monitor4 = {
    name = "monitor4"
    tags = { creator = "monitor4"
  } }
  dbadmin1 = {
    name = "dbadmin1"
    tags = { creator = "dbadmin1"
  } }
  dbadmin2 = {
    name = "dbadmin2"
    tags = { creator = "dbadmin2"
  } }
}

