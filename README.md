# terraform-ubuntu

Use terraform to create a EC2 instance to SSH into quickly.

The purpose is to create an easily creatable and easily destroyable environment to use or test with.

- Use `terraform apply --auto-approve` to create infrastructure in AWS EC2.
- Take note of the output `public_ip`.
- A SSH private key "ec2-controller-private-key.pem" file should be created in the repository.
- Now you can SSH to the created instance with `ssh -i ec2-controller-private-key.pem ubuntu@<YOUR_PUBLIC_IP>`.
