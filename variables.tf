variable "gcp_project" {
  description = "GCP Project ID"
}

variable "gcp_region" {
  description = "GCP region to deploy in"
}

variable "aws_region" {
  description = "AWS region to deploy in"
}

variable "gcp_cidr_range" {
  description = "CIDR range for the GCP VPC"
}

variable "gcp_subnet" {
  description = "CIDR range for the GCP subnet"
}

variable "gcp_asn" {
  description = "ASN to use in GCP"
}

variable "aws_cidr_range" {
  description = "CIDR range for the AWS VPC"
}
