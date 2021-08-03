provider "aws" {

     region = "${var.region}" 

}


resource "aws_key_pair" "default" {
  key_name = "ec2-nginx-key-01"
  public_key = "${file("${var.key_path}")}"

}


resource "aws_instance" "ec2" {
    
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    key_name = "${aws_key_pair.default.id}"
    vpc_security_group_ids = ["${aws_security_group.default.name}"]
    user_data = "${file("install_nginx.sh")}"

    provisioner "local-exec" {
    	command = "sleep 45 && python  testwebsite.py  ${aws_instance.ec2.public_ip}"
   }

   
 connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}" 
    host     = "${aws_instance.ec2.public_ip}"

}

 provisioner "local-exec" {
    

    command = "scp -r -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${aws_instance.ec2.public_ip}:/var/log/nginx/access.log . "


  }

  
    tags = {
        Name = "webserver-nginx"
    }

}

resource "aws_security_group" "default" {

    name = "ec2-nginx-sg-01"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }


    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

output "DNS" {
  value = aws_instance.ec2.public_dns
}

resource "aws_s3_bucket" "example" {
  bucket = "kroton-testbackup-2021"
  acl = "private"
  versioning {
    enabled = true
  }

  }


resource "aws_s3_bucket_object" "object" {
  depends_on = ["aws_s3_bucket.example"]
  bucket = "kroton-testbackup-2021"
  key    = "access.log"
  source = "access.log"
  etag = "${filemd5("access.log")}"
}







