resource "aws_route_table" "public" {


 vpc_id = aws_vpc.main.id


 route {


  cidr_block = "0.0.0.0/0"


  gateway_id = aws_internet_gateway.main.id


 }


 tags = {


 Name = "${var.environment}-public-route"

 }


}


resource "aws_route_table" "private" {


 vpc_id = aws_vpc.main.id


 route {


 cidr_block = "0.0.0.0/0"


 nat_gateway_id = aws_nat_gateway.main.id


 }


 tags = {


 Name = "${var.environment}-private-route"


 }


}