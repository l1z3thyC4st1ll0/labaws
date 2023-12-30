resource "aws_instance" "PublicEC2_1" { 
        ami = "ami-010b4f3cc590406f3" 
        availability_zone = "us-east-1a" 
        instance_type = "t2.micro" 
        key_name = "deployer-key"
        subnet_id = "${aws_subnet.PublicSub1.id}"
        vpc_security_group_ids = [aws_security_group.allow_tls.id] 
        private_ip = "10.0.128.50"
        tags = { 
        Name = "PublicEC2_windows" 
  }
    user_data =  <<-EOF
      <powershell>
    Start-Sleep -Seconds 120
    
    #Download Git installer
    Set-ExecutionPolicy RemoteSigned -Force
    $installerPath = "C:\Git-2.32.0-64-bit.exe"
    $installerArgs = "/SILENT"

    Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.32.0.windows.1/Git-2.32.0-64-bit.exe" -OutFile $installerPath
    Start-Process -Wait -FilePath $installerPath -ArgumentList $installerArgs -Verb RunAs


    # Add Git to PATH environment variable
    $GitPath = "C:\Program Files\Git\bin"
    $EnvPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    [Environment]::SetEnvironmentVariable("PATH", "$EnvPath;$GitPath", "Machine")
    # Install IIS
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools
    # Create a new website
    $docroot = "C:\\inetpub\\wwwroot"
    New-Item -ItemType Directory -Force -Path $docroot
    Set-WebConfigurationProperty -Filter /system.webServer/directoryBrowse -Name enabled -Value True -PSPath IIS:\ -Verbose
    New-Website -Name "My Website" -PhysicalPath $docroot -Port 80 -Force -Verbose
    # Copy website files to web root directory
    Copy-Item -Path C:\\github\\* -Destination $docroot -Recurse -Force -Verbose
    </powershell>
    EOF
}

  resource "aws_instance" "PublicEC2_2"{
        ami = "ami-023c11a32b0207432"
        availability_zone = "us-east-1a"
        instance_type = "t2.micro"
        subnet_id = "${aws_subnet.PublicSub1.id}"
        vpc_security_group_ids = [aws_security_group.allow_tls.id] 
        tags = { 
        Name = "PublicEC2_redhat" 
 }
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              service httpd start
              chkconfig httpd on
              EOF
}
resource "aws_instance" "PublicEC2_3" { 
        ami = "ami-010b4f3cc590406f3" 
        availability_zone = "us-east-1a" 
        instance_type = "t2.micro" 
        key_name = "deployer-key"
        subnet_id = "${aws_subnet.PublicSub1.id}"
        vpc_security_group_ids = [aws_security_group.allow_tls.id] 
        private_ip = "10.0.128.51"
        tags = { 
        Name = "PublicEC3_windows" 
  }

}
resource "aws_instance" "PrivateEC2_1" { 
        ami = "ami-0b9fb2d6834800260" 
        availability_zone = "us-east-1a" 
        instance_type = "t2.micro" 
        key_name = "deployer-key"
        subnet_id = "${aws_subnet.PrivateSub1.id}"
        vpc_security_group_ids = [aws_security_group.allow_local.id]
        tags = { 
        Name = "PrivateEC2_suse" 
  }
        user_data = <<-EOF
        #!/bin/bash
# Use this for your user data (script from top to bottom)
yum update 
yum install httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
EOF
}
resource "aws_instance" "nginx1" {
        ami = "ami-079db87dc4c10ac91"
        instance_type = "t2.micro" 
        subnet_id = "${aws_subnet.PrivateSub1.id}"
        vpc_security_group_ids = [aws_security_group.allow_local.id]
        private_ip = "10.0.0.20"
        key_name = "deployer-key"
        

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Taco Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF

  tags = { 
        Name = "PrivateEC2_linux" 
  }

}
resource "aws_instance" "PrivateEC2_2"{
        ami = "ami-023c11a32b0207432"
        availability_zone = "us-east-1a"
        instance_type = "t2.micro"
        count = 2
        subnet_id = "${aws_subnet.PrivateSub2.id}"
        vpc_security_group_ids = [aws_security_group.allow_local.id]
        tags = { 
        Name = "PrivateEC2_Redhat" 
  }

}
